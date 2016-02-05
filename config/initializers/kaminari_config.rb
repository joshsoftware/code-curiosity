Kaminari.configure do |config|
   config.default_per_page = 10
   config.max_per_page = 10
   config.window = 4
   config.outer_window = 1
   config.left = 2
   config.right = 4
   config.page_method_name = :page
   config.param_name = :page
end
