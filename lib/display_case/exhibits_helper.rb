module ExhibitsHelper
  def exhibit(model, context=self)
    Exhibit.exhibit(model, context)
  end
end
