# frozen_string_literal: true

class REST::DomainBlockSerializer < ActiveModel::Serializer
  attributes :domain, :digest, :severity, :comment

  def domain
    ""
  end

  def digest
    ""
  end

  def comment
    ""
  end
end
