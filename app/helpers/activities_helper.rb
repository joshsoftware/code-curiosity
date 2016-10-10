module ActivitiesHelper

  def score_css_class(value)
    classes = {
      0 => 'zero',
      1 => 'one',
      2 => 'two',
      3 => 'three',
      4 => 'four',
      5 => 'five'
    }

    classes[value]
  end

  def markdown(description)
    raw MARKDOWN.render(description)
  end

end
