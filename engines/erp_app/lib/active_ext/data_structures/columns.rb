class ActiveExt::DataStructures::Columns
  include Enumerable

  # This collection is referenced by other parts of ActiveExt and by methods within this DataStructure.
  # IT IS NOT MEANT FOR PUBLIC USE (but if you know what you're doing, go ahead)
  def _inheritable=(value)
    @sorted = true
    @_inheritable = value
  end

  # This accessor is used by ActionColumns to create new Column objects without adding them to this set
  attr_reader :active_record_class

  def initialize(active_record_class, *args)
    @active_record_class = active_record_class
    @_inheritable = []
    @set = []

    self.add *args
  end

  # the way to add columns to the set. this is primarily useful for virtual columns.
  # note that this also makes columns inheritable
  def add(*args)
    args.flatten! # allow [] as a param
    args = args.collect{ |a| a.to_sym }

    # make the columns inheritable
    @_inheritable.concat(args)
    # then add columns to @set (unless they already exist)
    args.each { |a| @set << ActiveExt::DataStructures::Column.new(a.to_sym, @active_record_class) unless find_by_name(a) }
  end
  alias_method :<<, :add

  def exclude(*args)
    # only remove columns from _inheritable. we never want to completely forget about a column.
    args.each { |a| @_inheritable.delete a }
  end

  # returns an array of columns with the provided names
  def find_by_names(*names)
    @set.find_all { |column| names.include? column.name }
  end

  # returns the column of the given name.
  def find_by_name(name)
    # this works because of `def column.=='
    column = @set.find { |c| c.name == name }
    column
  end
  alias_method :[], :find_by_name

  def each
    @set.each {|i| yield i }
  end
end