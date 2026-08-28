class Shared::Navbar < Bridgetown::Component
  LINKS = [
    { label: "Home", path: "/" },
    { label: "Organizers", path: "/organizers" },
    { label: "Venue", path: "/venue" },
    { label: "Code of Conduct", path: "/code-of-conduct" },
  ].freeze

  def initialize(metadata:, resource:)
    @metadata, @resource = metadata, resource
  end

  def links
    LINKS
  end

  # Marks the nav entry for the page being rendered so it can carry
  # aria-current="page".
  def current?(path)
    normalize(current_url) == normalize(path)
  end

  private

  def current_url
    @resource.relative_url if @resource.respond_to?(:relative_url)
  end

  def normalize(url)
    trimmed = url.to_s.delete_prefix("/").delete_suffix("/")
    trimmed.empty? ? "/" : "/#{trimmed}"
  end
end
