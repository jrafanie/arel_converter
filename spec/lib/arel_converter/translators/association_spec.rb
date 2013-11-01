require 'spec_helper'

describe ArelConverter::Translator::Association do
  
  context 'parsing has_and_belongs_to_many' do
    #-  has_and_belongs_to_many :groups, :uniq => true
#-  has_and_belongs_to_many :products, :uniq => true
#-  has_and_belongs_to_many :affiliate_sales_orders
  
    it 'should not change if there are no options' do
      finder = %Q{has_and_belongs_to_many :posts}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_and_belongs_to_many :posts})
    end

    it 'should translate options' do
      finder = %Q{has_and_belongs_to_many :posts, :uniq => true}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_and_belongs_to_many :posts, -> { uniq(true) }})
    end

  end


  context 'parsing has_one' do
    it 'should ignore if no options set' do
      finder = %Q{has_one :posts}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_one :posts})
    end

    it 'should translate options' do
      finder = %Q{has_one :posts, :conditions => ['posts.active = ?', true]}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_one :posts, -> { where("posts.active = ?", true) }})
    end

    context 'with options' do

      %w[as autosave class_name dependent foreign_key inverse_of 
         primary_key source source_type through validate].each do |option|

        it "should handle the #{option} option" do
          finder = %Q{has_one :posts, :#{option} => 'Sheet'}
          expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_one :posts, #{option}: "Sheet"})
        end

        it "such as #{option} with scoping" do
          finder = %Q{has_one :posts, :#{option} => 'Sheet', :conditions => ['posts.active = ?', true]}
          expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_one :posts, -> { where("posts.active = ?", true) }, #{option}: "Sheet"})
        end

      end

      it 'should handle multiple options' do
        finder = %Q{has_one :posts, :as => 'Sheet', :through => :roles}
        expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_one :posts, as: "Sheet", through: :roles})
      end
    end
  end


  context 'parsing has_many' do
    it 'should ignore if no options set' do
      finder = %Q{has_many :posts}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_many :posts})
    end

    it 'should translate options' do
      finder = %Q{has_many :posts, :conditions => ['posts.active = ?', true]}
      expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_many :posts, -> { where("posts.active = ?", true) }})
    end

    context 'with options' do

      %w[as autosave class_name dependent foreign_key inverse_of 
         primary_key source source_type through validate].each do |option|

        it "should handle the #{option} option" do
          finder = %Q{has_many :posts, :#{option} => 'Sheet'}
          expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_many :posts, #{option}: "Sheet"})
        end

        it "such as #{option} with scoping" do
          finder = %Q{has_many :posts, :#{option} => 'Sheet', :conditions => ['posts.active = ?', true]}
          expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_many :posts, -> { where("posts.active = ?", true) }, #{option}: "Sheet"})
        end

      end

      it 'should handle multiple options' do
        finder = %Q{has_many :posts, :as => 'Sheet', :through => :roles}
        expect(ArelConverter::Translator::Association.translate(finder)).to eq(%Q{has_many :posts, as: "Sheet", through: :roles})
      end
    end

  end

end

