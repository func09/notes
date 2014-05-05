require "rubygems"
namespace :pdf do
  desc "Create PDF"
  task :create do
    inputfile = "build/html5/sample2.html"
    tmpfile = "tmp/tmp.pdf"
    outfile = "tmp/notebook.pdf"
    `wkhtmltopdf --outline --margin-top 0 --margin-left 0 --margin-right 0 --margin-bottom 0 --page-height 210 --page-width 130 --disable-smart-shrinking #{inputfile} #{tmpfile}`
    `pdfjam --landscape --booklet true --nup 2x1 --outfile #{outfile} #{tmpfile}`
    # `pdfjam --landscape --signature 8 --booklet true --outfile #{outfile} #{tmpfile}`
  end
end
