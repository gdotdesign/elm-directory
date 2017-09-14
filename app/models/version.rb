# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  package_id     :integer
#  version        :string
#  package_json   :json
#  documentation  :json
#  readme         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  effect_manager :boolean
#

class Version < ActiveRecord::Base
  belongs_to :package

  scope :visible, lambda {
    where("documentation::text != '[]' AND
           package_json->>'exposed-modules' != '[]'")
      .order("string_to_array(version, '.')::int[] desc")
  }

  def to_param
    version
  end

  def experimental?
    (Semantic::Version.new version).major < 1
  end

  def summary
    package_json['summary']
  end

  def dependencies
    package_json['dependencies'].to_h
  end

  def not_native?
    !package_json['native-modules']
  end

  def native?
    !not_native?
  end

  def elm_version
    package_json['elm-version']
  end
end
