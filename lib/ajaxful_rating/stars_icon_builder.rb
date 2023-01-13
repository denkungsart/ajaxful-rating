module AjaxfulRating # :nodoc:
  class StarsIconBuilder # :nodoc:
    include AjaxfulRating::Locale

    attr_reader :rateable, :user, :options, :remote_options, :template

    delegate :content_tag, :concat, :fas_icon, :far_icon, :link_to, :safe_join, to: :template

    def initialize(rateable, user_or_static, template, options = {}, remote_options = {})
      @user = user_or_static unless user_or_static == :static
      @rateable = rateable
      @template = template
      apply_stars_builder_options!(options, remote_options)
      @show_value = calculate_show_value
    end

    def calculate_show_value
      if options[:show_user_rating]
        rate = rateable.rate_by(user, options[:dimension]) if user
        rate ? rate.stars : 0
      else
        rateable.rate_average(true, options[:dimension])
      end
    end

    def render
      options[:wrap] ? wrapper_tag : ratings_tag
    end

    private
      def apply_stars_builder_options!(options, remote_options)
        @options = {
          wrap: true,
          show_user_rating: false,
          force_static: false,
          current_user: (template.current_user if template.respond_to?(:current_user))
        }.merge(options)

        # Do not see the need at the moment
        # @options[:show_user_rating] = @options[:show_user_rating].to_s == "true"
        # @options[:wrap] = @options[:wrap].to_s == "true"

        @remote_options = {
          url: nil,
          method: :post
        }.merge(remote_options)

        if @remote_options[:url].nil?
          rateable_name =  ActionView::RecordIdentifier.dom_class(rateable)
          url = "rate_#{rateable_name}_path"
          if template.respond_to?(url)
            @remote_options[:url] = template.send(url, rateable)
          else
            raise(Errors::MissingRateRoute)
          end
        end
      end

      def ratings_tag
        max_stars = rateable.class.max_stars.to_f
        content_tag(:ul, class: "ajaxful-rating", data: { controller: "star" }) do
          concat safe_join(Array.new(max_stars) { |i| star_tag(i+1) })
        end
      end

      def star_tag(value)
        already_rated = rateable.rated_by?(user, options[:dimension]) if user && !rateable.axr_config(options[:dimension])[:allow_update]
        css_class = "stars-#{value}"
        content_tag(:li) do
          # maybe fix :current_user option/ since what is the point of passing it as an option?
          if !options[:force_static] && !already_rated && user && options[:current_user] == user
            link_star_tag(value, css_class)
          else
            content_tag(:span, star_icon(value), class: css_class, title: i18n(:current))
          end
        end
      end

      def star_icon(value)
        icon_options = {
          data: {
            star_target: "star",
            star_star_index_param: value - 1,
            action: "pointerenter->star#enter
              pointerleave->star#leave"
          }
        }
        if value <= @show_value
          fas_icon("star", icon_options)
        else
          far_icon("star", icon_options)
        end
      end

      def link_star_tag(value, css_class)
        query = remote_options.fetch(:params, {}).merge(
          stars: value,
          dimension: options[:dimension],
          show_user_rating: options[:show_user_rating]
        ).to_query

        options = {
          class: css_class,
          title: i18n(:hover, value),
          method: remote_options[:method] || :post,
          remote: true
        }

        href = "#{remote_options[:url]}?#{query}"

        link_to(star_icon(value), href, options)
      end
      
      def wrapper_tag
        content_tag(:div, ratings_tag, class: "ajaxful-rating-wrapper",
                                                 id: rateable.wrapper_dom_id(options))
      end
  end
end
