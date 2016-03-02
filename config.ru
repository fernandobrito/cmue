#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

require 'rack/session/moneta'

use Rack::Session::Moneta, store: Moneta.new(:DataMapper, expires: true, repository: :default,
                                             setup: ENV['DATABASE_URL'] || 'postgres://postgres:postgres@localhost/cmue')

run Padrino.application