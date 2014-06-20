require 'active_support/all'
require 'middleman-notes'

class Page
  def initialize(prefix = "page", format = "%03d")
    @prefix = prefix
    @format = format
    @page   = 0
  end

  def countup
    @page += 1
    self
  end

  def to_s
    @prefix + @format % @page
  end
end

ignore "notebook/week_calendar_memo.html"

YEAR = 2014
MONTHS = Date.new(2014, 7) .. Date.new(2014, 12)

page = Page.new

# COVER
proxy "/notebook/#{page.countup}.html", "notebook/cover.html", locals: { direction: :right, months: MONTHS }, ignore: true

# YEAR
YEAR.step(YEAR + 1).each.with_index do |year, index|
  proxy "/notebook/#{page.countup}.html",
    "notebook/year_calendar.html",
    locals: {
      year: Date.new(YEAR + index),
      direction: index.even? ? :left : :right, },
    ignore: true
end

(Date.new(YEAR).beginning_of_year .. Date.new(YEAR).end_of_year).select{|d| d.day == 1}.
  in_groups_of(3).each.with_index do |group, index|
    year = group.first
    proxy "/notebook/#{page.countup}.html",
      "notebook/year_index.html",
      locals: {
        year: year,
        months: group,
        direction: index.even? ? :left : :right },
      ignore: true
  end

year = Date.new(YEAR)
proxy "/notebook/#{page.countup}.html", "notebook/year_plan.html",
  locals: { direction: :left, year: year },
  ignore: true
proxy "/notebook/#{page.countup}.html", "notebook/year_plan.html",
  locals: { direction: :right, year: year },
  ignore: true

MONTHS.select{|d| d.day == 1}.each.with_index do |m, n|
  # PLAN
  proxy "/notebook/#{page.countup}.html",
    "notebook/month_plan.html",
    locals: { direction: :left, month: m },
    ignore: true

  proxy "/notebook/#{page.countup}.html",
    "notebook/month_plan.html",
    locals: { direction: :right, month: m },
    ignore: true
end

MONTHS.select{|d| d.day == 1}.each.with_index do |m, n|
  # MONTH
  proxy "/notebook/#{page.countup}.html",
    "notebook/month_calendar.html",
    locals: { month: m, direction: :left },
    ignore: true
  proxy "/notebook/#{page.countup}.html",
    "notebook/month_calendar.html",
    locals: { month: m, direction: :right },
    ignore: true
end

MONTHS.select{|d| d.wday == 0}.each.with_index do |week, n|

  # WEEKLY
  proxy "/notebook/#{page.countup}.html", "notebook/week_calendar_vertical.html",
    locals: { month: week.beginning_of_month,
      week: week,
      direction: :left },
    ignore: true

  proxy "/notebook/#{page.countup}.html", "notebook/week_calendar_vertical.html",
    locals: { month: week.beginning_of_month,
      week: week,
      direction: :right },
    ignore: true

end

helpers do
  def ja_wdays
    %w(日 月 火 水 木 金 土)
  end
end

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

activate :autoprefixer

# Build-specific configuration
configure :build do
  activate :relative_assets
end

activate :notes do |notes|
  notes.page_width = 130
  notes.page_height = 210
end
