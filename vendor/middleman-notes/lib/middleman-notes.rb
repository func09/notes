require 'middleman-core'
require 'middleman-core/cli'

# Extension namespace
class Notes < ::Middleman::Extension

  option :page_width, 130, 'An example option'
  option :page_height, 210, 'An example option'

  def initialize(app, options_hash={}, &block)
    super
  end

  def after_configuration
    # Do something
  end

  # A Sitemap Manipulator
  # def manipulate_resource_list(resources)
  # end

  helpers do
    def wday_style_name(date, ignores: [])
      klasses = []
      klasses << date.strftime("%a").downcase
      klasses << date.strftime("%b").downcase unless ignores.include?(:month)
      klasses << :holiday if !ignores.include?(:holiday) && date.national_holiday?
      klasses
    end
  end

end

module Middleman::Cli
  class Notes < Thor
    include Thor::Actions

    namespace :notes

    desc 'notes pdf', 'Create Notes PDF'
    method_option "name",
      aliases: "-n",
      default: "notebook",
      desc: "The name of pdf file (defaults to notebook)"

    method_option "type",
      aliases: "-t",
      default: :spread,
      desc: "Select PDF type, spread or booklet (defaults to spread)"

    def notes(arg)
      if shared_instance.extensions.has_key?(:notes)
        ext_options = shared_instance.extensions[:notes].options

        case arg.to_sym
        when :pdf
          pdf(options, ext_options)
        else
          raise ArgumentError.new
        end
      else
        raise Thor::Error.new "You need to activate the notes extension in config.rb"
      end
    end

    private

    def shared_instance
      ::Middleman::Application.server.inst
    end

    def pdf(options, ext_options)
      name = options[:name]
      width = ext_options[:page_width]
      height = ext_options[:page_height]

      input_files = Dir.glob(shared_instance.root_path.join('build', name, "page*.html"))

      puts "Generate pdf `#{width}x#{height}`, name is #{name}"

      case options[:type].to_sym
      when :booklet
        tmp_file    = "build/#{name}_tmp.pdf"
        output_file = "build/#{name}.pdf"

        system wkhtmltopdf_cmd(input_files.join(' '), tmp_file, width: width, height: height)
        system pdfjam_cmd(tmp_file, output_file, booklet: true)

      when :spread
        input_files.unshift shared_instance.root_path.join('build', name, "blank.html")
        tmp_file    = "build/#{name}_tmp.pdf"
        output_file = "build/#{name}.pdf"

        system wkhtmltopdf_cmd(input_files.join(' '), tmp_file, width: width, height: height)
        system pdfjam_cmd(tmp_file, output_file, booklet: false)
      else
      end
    end

    def wkhtmltopdf_cmd(input, output, width: 130, height: 210 )
      <<-CMD
        bundle exec wkhtmltopdf --outline --margin-top 0 --margin-left 0 --margin-right 0 --margin-bottom 0 \
          --page-height #{height} --page-width #{width} \
          #{input} #{output}
      CMD
    end

    def pdfjam_cmd(input, output, booklet: true)
      <<-CMD
        pdfjam --landscape --nup 2x1 \
          #{ booklet ? "--booklet true " : "" } \
          --outfile #{output} #{input}
      CMD
    end
  end
end

Notes.register(:notes)
