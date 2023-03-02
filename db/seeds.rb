require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require "uri"
require "json"
require "net/http"

ProgramsController.new.fetch_cities
ProgramsController.new.fetch_programs
