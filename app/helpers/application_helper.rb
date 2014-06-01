module ApplicationHelper
	def capitalize_as_title (string)
		string.split.map(&:capitalize).join(' ')
	end
end
