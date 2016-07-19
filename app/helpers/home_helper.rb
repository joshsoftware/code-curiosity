module HomeHelper
	def get_advertised_groups
		@group = Group.where(advertise: true)
	end
end
