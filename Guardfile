guard :rspec do
  watch(%r{^spec/(.+)})
  watch(%r{^lib/rack/(.+)\.rb$}) { |m| "spec/lib/rack/#{m[1]}_spec.rb" }
end
