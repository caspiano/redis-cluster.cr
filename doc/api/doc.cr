# coding: utf-8

list = File.read_lines("#{__DIR__}/list").map(&.chomp)
impl = File.read_lines("#{__DIR__}/impl").map(&.chomp)
test = File.read_lines("#{__DIR__}/test").map(&.chomp)
note = File.read("#{__DIR__}/note")

group = nil
items = [] of String

count = ->(g : String) { list.count(&.=~ /^#{g}\t/) }
note_for = ->(key : String) {
  note.scan(/^#{key}\t(.*?)$/m) do
    return $1
  end

  nil
}

flush = ->(g : String?) {
  return if g.nil?
  return if items.empty?

  # Ignore cluster methods because no needs to implement.
  if g == "cluster"
    items.clear
    return
  end

  max = items.map(&.size).max + 2
  all = count.call(g)
  ok = items.count &.in?(impl)
  cat = g.split("_").join(' ', &.capitalize)
  puts "### #{cat} (#{ok} / #{all})"
  puts ""
  puts "|%-#{max}s|impl|test|note|" % "Command"
  puts "|%s|:--:|:--:|----|" % ("-" * max)

  items.each do |key|
    name = "%-#{max}s" % "`#{key}`"
    implemented = impl.includes?(key) ? "  ✓ " : "    "
    tested = test.includes?(key) ? "  ✓ " : "    "
    noted = note_for.call(key) || "    "
    puts "|#{name}|#{implemented}|#{tested}|#{noted}|"
  end
  puts ""
  items.clear
}

# Main

puts "# Supported API"

impl_cnt = (list.flat_map(&.split(/\t/, 2).last) & impl).size
puts "## Implemented %d%% (%d/%d)" % [(impl_cnt*100/list.size), impl_cnt, list.size]

list.each do |line|
  g, n = line.chomp.split(/\t/, 2)
  flush.call(group) if group != g
  group = g
  items << n
end

flush.call(group)
