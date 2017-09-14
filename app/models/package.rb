# == Schema Information
#
# Table name: packages
#
#  id         :integer          not null, primary key
#  repository :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stars      :integer
#  pushed_at  :datetime
#

class Package < ActiveRecord::Base
  has_many :visible_versions, -> { visible }, class_name: :Version
  has_one :latest_version, -> { visible }, class_name: :Version
  has_many :versions, dependent: :delete_all

  scope :visible, lambda {
    joins(:visible_versions)
      .distinct
      .order(stars: :desc)
  }

  scope :recent, lambda {
    joins(:visible_versions)
      .distinct
      .order(pushed_at: :desc)
  }

  scope :effect_manager, lambda {
    joins(:versions)
      .includes(:latest_version)
      .where("
        version =
         (SELECT   version
          FROM     versions
          WHERE    package_id = packages.id
          ORDER BY String_to_array(version, '.')::INT[] DESC limit 1)
        AND package_json->>'exposed-modules' != '[]'
        AND documentation::text != '[]'
        AND effect_manager IS TRUE
      ")
      .distinct
      .order(stars: :desc)
  }

  scope :search, lambda {
    joins(:versions)
      .includes(:latest_version)
      .where("
        version =
         (SELECT   version
          FROM     versions
          WHERE    package_id = packages.id
          ORDER BY String_to_array(version, '.')::INT[] DESC limit 1)
        AND package_json->>'exposed-modules' != '[]'
        AND documentation::text != '[]'
      ")
      .distinct
      .order(stars: :desc)
  }

  scope :native, lambda {
    joins(:versions)
      .includes(:latest_version)
      .where("
        version =
         (SELECT   version
          FROM     versions
          WHERE    package_id = packages.id
          ORDER BY String_to_array(version, '.')::INT[] DESC limit 1)
        AND package_json->>'native-modules' = 'true'
        AND package_json->>'exposed-modules' != '[]'
        AND documentation::text != '[]'
      ")
      .distinct
      .order(stars: :desc)
  }

  def author
    repository.split('/').first
  end

  def repo
    repository.split('/').last
  end

  def to_param
    repository
  end
end
