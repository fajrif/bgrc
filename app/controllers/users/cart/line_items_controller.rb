class Users::Cart::LineItemsController < Users::BaseController

	def create
		# Find associated product and current cart
		@product = Product.find(params[:product_id])

		if @product.quantity >= params[:quantity].to_i
			unless @current_cart
				@current_cart = current_user.create_cart
			end

			# If cart already has this product then find the relevant line_item and iterate quantity otherwise create a new line_item for this product
			unless @current_cart.products.include?(@product)
				@current_cart.line_items << LineItem.new(product: @product, quantity: params[:quantity].to_i)
				@current_cart.save!
			else
				# Find the line_item with the chosen_product
				@line_item = @current_cart.line_items.find_by(:product_id => @product.id)
				# Iterate the line_item's quantity by params
				@line_item.quantity += params[:quantity].to_i
				@line_item.save!
			end

			# Save and redirect to product show path
			flash[:notice] = "Product added to your cart!"
		else
			flash[:alert] = "Product stock is not available!"
		end

		redirect_to product_path(@product)
	end

	def add
		@line_item = LineItem.find(params[:id])
		@line_item.quantity += 1
		@line_item.save
		redirect_to cart_path(@current_cart)
	end

	def reduce
		@line_item = LineItem.find(params[:id])
		if @line_item.quantity > 1
			@line_item.quantity -= 1
		end
		@line_item.save
		redirect_to cart_path(@current_cart)
	end

	def destroy
		@line_item = LineItem.find(params[:id])
		@line_item.destroy

		redirect_to users_cart_path, :alert => "Item deleted."
	end

	private

	def params_line_item
		params.require(:line_item).permit(:quantity,:product_id, :cart_id)
	end

end
