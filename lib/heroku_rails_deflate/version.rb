module HerokuRailsDeflate
  class Version
    MAJOR = 1
    MINOR = 0
    PATCH = 3
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
