#!/usr/bin/env ruby

require 'awesome_print'
require 'json'

local_dirname       = ARGV[0]
brakeman_json       = ARGV[1]
rubocop_json        = ARGV[2]
bundle_audit_output = ARGV[3]

if local_dirname.empty? || brakeman_json.empty? || rubocop_json.empty? || bundle_audit_output.empty?
  raise "Missing argument(s)"
end

puts "Local Dirname: #{local_dirname}"
puts "Brakeman JSON: #{brakeman_json}"
puts "Rubocop JSON: #{rubocop_json}"
puts "Bundle Audit Output: #{bundle_audit_output}"

ap JSON.parse(File.read(brakeman_json))
ap JSON.parse(File.read(rubocop_json))
ap File.read(bundle_audit_output)
