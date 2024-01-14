require 'casino_core/model'

class CASinoCore::Model::ProxyGrantingTicket < ActiveRecord::Base
  validates :ticket, uniqueness: true
  validates :iou, uniqueness: true
  belongs_to :granter, polymorphic: true
  has_many :proxy_tickets, dependent: :destroy
end
