class GribCommandConf < GribConf
  UNFLAG_PREFIX = "dont".freeze
  SHORT_PARAM_MAPPING = {
    "publish" => "p",
    "open" => "o",
    "guess-fields" => "g",
    }.freeze

  def initialize(argv = "", name = "grib_command_conf", parent = {})
    super({}, name, parent)
    parse(argv)
  end

  def parse(argv, &option_handler)
    opts = OptionParser.new do |opts|
      GribConf::VALID_OPTIONS.each do |pr_option|
        opts.on("--#{pr_option}=#{pr_option.upcase}", String) do |str|
          save_option pr_option, str, &option_handler
        end
      end

      GribConf::VALID_FLAGS.each do |pr_flag|
        args = ["--#{pr_flag}"]
        if (short = SHORT_PARAM_MAPPING[pr_flag])
          args << "-#{short}"
        end
        opts.on(*args) do
          save_option pr_flag, true, &option_handler
        end

        opts.on("--#{UNFLAG_PREFIX}-#{pr_flag}") do
          save_option pr_flag, false, &option_handler
        end
      end
    end
    opts.parse(argv)
  end

  private
  def save_option(opt, value, &option_handler)
    self[opt] = value
    option_handler.call(opt, value) if option_handler
  end
end