require 'active_support/all'

YEAR = 2014

# MONTHLY
YEAR.step(YEAR + 1).each.with_index do |year, index|
  proxy "/notebook/monthly/page_01_#{sprintf("%02d", index)}.html",
    "notebook/monthly/year_calendar.html",
    locals: {
      year: Date.new(YEAR + index),
      direction: index.even? ? :left : :right,
    },
    ignore: true
end

(Date.new(YEAR).beginning_of_year .. Date.new(YEAR).next_year.end_of_year).select{|d| d.day == 1}.
  in_groups_of(3).each.with_index do |group, index|
    year = group.first
    proxy "/notebook/monthly/page_02_#{sprintf("%02d", index)}.html", "notebook/monthly/year_index.html", locals: { year: year, months: group, direction: index.even? && :left }, ignore: true
  end


# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }


###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

helpers do
  def wday_style_name(date)
    klasses = []
    klasses << date.strftime("%A").downcase
    klasses << :holiday if date.national_holiday?
    klasses
  end
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :autoprefixer

# Build-specific configuration
configure :build do
  activate :relative_assets
end

set :page_width, 130
set :page_height, 210

after_build do |builder|
  inputfile = "build/notebook/monthly/page_*.html"
  tmpfile = "tmp/tmp.pdf"
  outfile = "tmp/notebook.pdf"
  `wkhtmltopdf --outline --margin-top 0 --margin-left 0 --margin-right 0 --margin-bottom 0 --page-height #{page_height} --page-width #{page_width} #{inputfile} #{tmpfile}`
  # `pdfjam --landscape --booklet true --nup 2x1 --outfile #{outfile} #{tmpfile}`
end
