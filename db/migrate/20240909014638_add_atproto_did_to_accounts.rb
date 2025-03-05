require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class AddAtprotoDidToAccounts < ActiveRecord::Migration[7.0]
  include Mastodon::MigrationHelpers
  disable_ddl_transaction!

  def up
    add_column :accounts, :atproto_did, :string
  end

  def down
    remove_column :accounts, :atproto_did
  end
end
