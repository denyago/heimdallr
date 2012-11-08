ActiveRecord::Base.logger = Logger.new('tmp/debug.log')
ActiveRecord::Base.configurations = YAML::load(IO.read('tmp/database.yml'))
ActiveRecord::Base.establish_connection('test')

ActiveRecord::Base.connection.create_table(:users) do |t|
  t.boolean     :admin
  t.boolean     :banned
end

ActiveRecord::Base.connection.create_table(:dont_saves) do |t|
  t.string      :name
end

ActiveRecord::Base.connection.create_table(:comments) do |t|
  t.belongs_to  :article
  t.boolean     :is_visible
end

ActiveRecord::Base.connection.create_table(:articles) do |t|
  t.belongs_to  :owner
  t.text        :content
  t.integer     :secrecy_level
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:base_news) do |t|
  t.string      :type
  t.timestamps
end

class ActiveRecord::User < ActiveRecord::Base; end

class ActiveRecord::DontSave < ActiveRecord::Base; end

class ActiveRecord::Comment < ActiveRecord::Base
  include Heimdallr::Model

  belongs_to :article

  def self.visible
    self.where(is_visible: true)
  end

  restrict do |user, record|
    scope :fetch
  end
end

class ActiveRecord::Article < ActiveRecord::Base
  include Heimdallr::Model

  belongs_to :owner, :class_name => 'ActiveRecord::User'
  has_many   :comments

  def dont_save=(name)
    ActiveRecord::DontSave.create :name => name
  end

  restrict do |user, record|
    if user.banned?
      # banned users cannot do anything
      scope :fetch, -> { where('1=0') }
    elsif user.admin?
      # Administrator or owner can do everything
      scope :fetch
      scope :delete
      can [:view, :create, :update, :foo]
    else
      # Other users can view only their own or non-classified articles...
      scope :fetch,  -> { where('owner_id = ? or secrecy_level < ?', user.id, 5) }
      scope :delete, -> { where('owner_id = ?', user.id) }

      # ... and see all fields except the actual security level
      # (through owners can see everything)...
      if record.try(:owner) == user
        can :view
        can :update, {
          secrecy_level: { inclusion: { in: 0..4 } }
        }
        can :foo
      else
        can    :view
        cannot :view, [:secrecy_level]
      end

      # ... and can create them with certain restrictions.
      can :create, %w(content)
      can :create, {
        owner_id:      user.id,
        secrecy_level: { inclusion: { in: 0..4 } }
      }
    end
  end
end

class ActiveRecord::SubArticle < ActiveRecord::Article; end

class ActiveRecord::BaseNews < ActiveRecord::Base
  include Heimdallr::Model

  restrict do |user, record|
      scope :fetch
      can :create
  end
end

class ActiveRecord::FancyNews < ActiveRecord::BaseNews; end
