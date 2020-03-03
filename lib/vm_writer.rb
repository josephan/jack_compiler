class VMWriter
  def initialize(filepath)
    @f = File.open(vm_code_filepath(filepath), "w+")
  end

  def write_push(segment, index)
    f.puts("push #{segment} #{index}")
  end

  def write_pop(segment, index)
    f.puts("pop #{segment} #{index}")
  end

  def write_arithmetic(command)
    # add, sub, neg, eq, gt, lt, and, or, not
    f.puts("#{command}")
  end

  def write_label(label)
    f.puts("label #{label}")
  end

  def write_goto(label)
    f.puts("goto #{label}")
  end

  def write_if(label)
    f.puts("if-goto #{label}")
  end

  def write_call(name, n_args)
    f.puts("call #{name} #{n_args}")
  end

  def write_function(name, n_locals)
    f.puts("function #{name} #{n_locals}")
  end

  def write_return
    f.puts("return")
  end

  def close
    f.close
  end

  private

  attr_reader :f

  def vm_code_filepath(filepath)
    filepath.gsub(".jack", ".vm")
  end
end
