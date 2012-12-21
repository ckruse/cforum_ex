# -*- encoding: utf-8 -*-

class CfNotification < ActiveRecord::Base
  self.primary_key = 'notification_id'
  self.table_name  = 'notifications'

  attr_accessible :notification_id, :recipient_id, :is_read,
    :path, :subject, :created_at,
    :updated_at

  belongs_to :recipient, class_name: 'CfUser', :foreign_key => :recipient_id

  validates :subject, presence: true, length: {in: 2..250}
  validates :body, presence: true, length: {in: 5..12288}

  validates :recipient_id, presence: true
end

# eof
