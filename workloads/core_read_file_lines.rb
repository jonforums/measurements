fname = File.join(RCI_ROOT, 'input', 'lesmiserables.txt')

count = 0
File.open(fname, 'r').each_line do |line|
  count += 1
end
