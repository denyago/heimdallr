require 'spec_helper'
require 'mongoid/models'

require 'proxy_examples'

describe Heimdallr::Proxy do
  context 'with Mongoid' do
    run_specs(Mongoid::User, Mongoid::Article, Mongoid::DontSave, Mongoid::Comment)

    context 'with subclass' do
      run_specs(Mongoid::User, Mongoid::SubArticle, Mongoid::DontSave, Mongoid::Comment)
    end
  end
end
