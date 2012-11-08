require 'spec_helper'
require 'active_record/models'

require 'proxy_examples'
require 'proxy_sti_examples'

describe Heimdallr::Proxy do
  context 'with ActiveRecord' do
    run_specs(ActiveRecord::User, ActiveRecord::Article, ActiveRecord::DontSave, ActiveRecord::Comment)

    context 'with subclass' do
      run_specs(ActiveRecord::User, ActiveRecord::SubArticle, ActiveRecord::DontSave, ActiveRecord::Comment)
    end

    context 'with STI' do
      run_sti_specs(ActiveRecord::BaseNews, ActiveRecord::FancyNews)
    end
  end
end
