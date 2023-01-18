// From: https://dev.to/tonyrowan/adding-a-star-rating-with-hotwire-4p02
// Copied from: https://github.com/denkungsart/ajaxful-rating
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star"];

  enter(event) {
    this._fillToStar(event.params.starIndex);
  }

  leave() {
    this._fillToStar(-1);
  }

  _fillToStar(star) {
    this.starTargets.forEach((target, index) => {
      if (index <= star) {
        target.classList.add("hover");
      } else {
        target.classList.remove("hover");
      }
    });
  }
}
