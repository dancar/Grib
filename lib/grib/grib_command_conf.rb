require 'optparse'
class GribCommandConf < GribConf
  UNFLAG_PREFIX = "dont".freeze
  UNOPTION_PREFIX = "no".freeze
  SHORT_PARAM_MAPPING = {
    "publish" => "p",
    "open" => "o",
    "guess-fields" => "g",
    "review-request-id" => "r",
    "skip-alignment-assertion" => "S"
    }.freeze
  COMMAND_LINE_UNIQUE_OPTIONS = {
    "new" => "Ignore existing review-request-id and ask to create a new one",
    "skip-alignment-assertion" => "Skip alignment-assertion",
    "info" => "Do not execute post-review, only show branch info",
    "dry" => "Dry-run - do not execute post-review, only read configurations and show the command",
    "full-info" => "Same as --info, but shows unspecified configurations as well"
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

        opts.on("--no-#{pr_option}") do
          save_option pr_option, nil
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

      COMMAND_LINE_UNIQUE_OPTIONS.each do |cmd_flag, desc|
        args = ["--#{cmd_flag}"]
        if (short = SHORT_PARAM_MAPPING[cmd_flag])
          args << "-#{short}"
        end
        args << desc
        opts.on(*args) do
          self[cmd_flag] = true
        end
      end
    end
    parse(argv, &option_handler)
  end

  def parse(argv, &option_handler)
    @option_handler = option_handler if option_handler
    begin
      @opts.parse(argv)
    rescue OptionParser::ParseError => e
      $LOG.error e.message
    end
  end

  def []=(k,v)
    super(k,v, COMMAND_LINE_UNIQUE_OPTIONS.include?(k))
  end

  def [](k)
    return nil if k == "review-request-id" and self["new"]
    return super(k)
  end

  private
  def save_option(opt, value)
    self[opt] = value
    @option_handler.call(opt, value) if @option_handler
  end
end
