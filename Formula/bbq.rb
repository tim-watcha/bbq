class Bbq < Formula
  desc "BaBigQuery: Too young to do anything dangerous. A safe bq CLI wrapper."
  homepage "https://github.com/tim-watcha/bbq"
  url "https://github.com/tim-watcha/bbq/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "70887edb65def0afd699a60e9bfde4bf5d6f3f63040a056f68820e7a9ac792bf"
  license "MIT"


  def install
    bin.install "bbq"
  end

  test do
    # bbq with no args prints usage and exits 0
    assert_match "BaBigQuery", shell_output("#{bin}/bbq")
  end
end
