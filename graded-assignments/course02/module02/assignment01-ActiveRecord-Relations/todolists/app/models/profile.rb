class Profile < ActiveRecord::Base
  belongs_to :user

  validates :gender, inclusion: ['female', 'male']
  validate :not_all_null
  validate :not_sue_in_first_name

  def not_all_null
    if last_name.nil? && first_name.nil?
      errors.add(:last_name, 'last name and first name cannot both be null!')
    end
  end

  def not_sue_in_first_name
    if gender == 'male' and first_name == 'Sue'
      errors.add(:first_name, 'make should not have first name Sue!')
    end
  end

  def get_all_profiles min, max
    Profile.where('birth_year between ? and ?', min, max).order(birth_year: :asc)
  end
end
