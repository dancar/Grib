require 'optparse'
require 'lib/grib_conf'
class GribCommandConf < GribConf
  UNFLAG_PREFIX = "dont".freeze
  SHORT_PARAM_MAPPING = {
    "publish" => "p",
    "open" => "o",
    "guess-fields" => "g",
    "review-request-id" => "r"
    }.freeze

  def initialize(argv = "", name = "grib_command_conf", parent = {}, &option_handler)
    super({}, name, parent)
    @option_handler = option_handler
    @opts = OptionParser.new do |opts|
      GribConf::VALID_OPTIONS.each do |pr_option|
        short = SHORT_PARAM_MAPPING[pr_option]
        str = ""
        str << "-#{short}, " if short
        str << "--#{pr_option}=#{pr_option.upcase}"
        opts.on(str, String) do |str|
          save_option pr_option, str
        end
      end

      GribConf::VALID_FLAGS.each do |pr_flag|
        args = ["--#{pr_flag}"]
        if (short = SHORT_PARAM_MAPPING[pr_flag])
          args << "-#{short}"
        end
        opts.on(*args) do
          save_option pr_flag, true
        end

        opts.on("--#{UNFLAG_PREFIX}-#{pr_flag}") do
          save_option pr_flag, false
        end
      end
    end
    parse(argv, &option_handler)
  end

  def parse(argv, &option_handler)
    @option_handler = option_handler if option_handler
    @opts.parse(argv)
  end

  private
  def save_option(opt, value)
    self[opt] = value
    @option_handler.call(opt, value) if @option_handler
  end
end