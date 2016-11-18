require 'pathname'

class Builder # :nodoc:
  attr_reader :options
  attr_reader :order
  attr_reader :context

  def initialize(options, order: [])
    @options = options
    @order = order
    @context = Context.new
  end

  def run
    templates.each { |path| printer.print(path) }
  ensure
    template_rb.close unless stdout?
  end

  private

  def annotate?
    options[:annotate]
  end

  def stdout?
    options[:stdout]
  end

  def printer
    @printer ||= if annotate?
                   AnnotatedFilePrinter.new(out: out, context: context)
                 else
                   FilePrinter.new(out: out)
                 end
  end

  def templates
    if order.empty?
      Dir[context.templates]
    else
      order.map { |file_name| File.expand_path("template/#{file_name}.rb", context.root_dir) }
    end
  end

  def out
    return STDOUT if stdout?
    template_rb
  end

  def template_rb
    @template_rb ||= File.open(context.template_rb, 'w')
  end

  class Context # :nodoc:
    def root_dir
      File.expand_path('..', script_dir)
    end

    def script_dir
      File.dirname(__FILE__)
    end

    def templates
      File.expand_path('template/*.rb', root_dir)
    end

    def template_rb
      File.expand_path('template.rb', root_dir)
    end
  end

  class FilePrinter # :nodoc:
    attr_reader :out

    def initialize(out: STDOUT, context: nil)
      @out = out
      @context = context
    end

    def print(path)
      out.puts content(path)
    end

    private

    def content(path)
      "#{File.read(path)}\n"
    end
  end

  class AnnotatedFilePrinter < FilePrinter # :nodoc:
    attr_reader :context

    def initialize(args)
      super(args)
      @context = args.fetch(:context)
    end

    def print(path)
      out.puts source_comment(path)
      super(path)
    end

    private

    def source_comment(path)
      root_pname = Pathname.new(context.root_dir)
      pname = Pathname.new(path)
      "# Source: #{pname.relative_path_from(root_pname)}"
    end
  end
end
