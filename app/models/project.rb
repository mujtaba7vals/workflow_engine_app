class Project < ApplicationRecord
  
  PROJECT_CATEGORIES = %w[TEAM INDIVIDUAL].freeze

  validates :name, presence: true, uniqueness: true
  validates :project_category, presence: true, inclusion: { in: PROJECT_CATEGORIES }

  belongs_to :company

  has_many :project_teams, dependent: :destroy
  has_many :teams, through: :project_teams

  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users

  def team_project?
    project_category == PROJECT_CATEGORIES[0]
  end
  def available_users
    User.where.not(id: self.users.select(:id))
  end
  def available_teams
    Team.where.not(id: self.teams.select(:id))
  end
end