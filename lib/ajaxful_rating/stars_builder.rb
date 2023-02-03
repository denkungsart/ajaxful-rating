module AjaxfulRating # :nodoc:
  class StarsBuilder # :nodoc:
    include AjaxfulRating::Locale

    attr_reader :rateable, :user, :options, :remote_options, :template

    delegate :content_tag, :concat, :link_to, :safe_join, to: :template

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
        content_tag(:ul, class: "ajaxful-rating") do
          concat safe_join(Array.new(max_stars) { |i| star_tag(i+1) })
        end
      end

      def star_tag(value)
        already_rated = rateable.rated_by?(user, options[:dimension]) if user && !rateable.axr_config(options[:dimension])[:allow_update]
        css_class = "stars-#{value}"
        content_tag(:li) do
          if !options[:force_static] && !already_rated && user && options[:current_user] == user
            link_star_tag(value, css_class)
          else
            icon_options = options[:data_action].present? ? star_icon_options(value) : {}
            content_tag(:span, star_icon(value, icon_options), class: css_class, title: i18n(:current))
          end
        end
      end

      def star_icon(value, icon_options = {})
        if value <= @show_value
          content_tag(:i, nil, icon_options.merge(class: "fas fa-star"))
        else
          content_tag(:i, nil, icon_options.merge(class: "far fa-star"))
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

        link_to(star_icon(value, star_icon_options(value)), href, options)
      end

      def star_icon_options(value)
        icon_options = {
          data: {
            star_target: "star",
            star_star_index_param: value - 1,
            action: safe_join(["pointerenter->star#enter pointerleave->star#leave", options[:data_action]].compact_blank, " ")
          }
        }
        icon_options
      end
      
      def wrapper_tag
        content_tag(:div, ratings_tag, class: "ajaxful-rating-wrapper",
                                                 id: rateable.wrapper_dom_id(options[:dimension]))
      end
  end
end
