
%w(version client connection job version).each do |f|
  require_relative "allq/#{f}"
end

%w(base get delete done put release stats touch kick peek clear bury parent_job drain add_server).each do |f|
  require_relative "allq/actions/#{f}"
end

module Allq

  # Your code goes here...
end
