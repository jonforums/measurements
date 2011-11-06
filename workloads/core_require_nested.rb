in_dir = File.expand_path('../input/empty_files/a/b/c/d/e', File.dirname(__FILE__))

c = ENV['MEASURE_EXTENDED'] || 1

# XXX cheat using `unshift` to jump to the front
$LOAD_PATH.push in_dir

cache = $LOADED_FEATURES.dup
c.to_i.times do
  10.times do
    100.times do |i|
      require "nested_empty#{i}"
    end
    $LOADED_FEATURES.clear
    $LOADED_FEATURES.concat(cache)
  end
end

$LOAD_PATH.delete in_dir
