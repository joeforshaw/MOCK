class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  has_many :datasets, :dependent => :destroy
  has_many :runs,     :dependent => :destroy

  validates :name,  presence:   true,
                    length:     { maximum: 128 }

  validates :email, presence:   true,
                    uniqueness: true,
                    length:     { minimum: 3 }

end
