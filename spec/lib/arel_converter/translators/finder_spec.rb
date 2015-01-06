require 'spec_helper'

describe ArelConverter::Translator::Finder do

  context 'parsing .all' do
    it 'as a model method with no arguments' do
      finder = %Q{MyModel.all}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.all})
    end

    it 'as a model method' do
      finder = %Q{MyModel.all(:joins => [:payment_method], :conditions => ["payment_methodable_type = 'ChequePaymentMethod' AND amount > 0"])}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.joins(:payment_method).where("payment_methodable_type = 'ChequePaymentMethod' AND amount > 0")})
    end

    it 'as a chained method' do
      finder = %Q{self.payments.all(:joins => [:payment_method], :conditions => ["payment_methodable_type = 'ChequePaymentMethod' AND amount > 0"])}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.payments.joins(:payment_method).where("payment_methodable_type = 'ChequePaymentMethod' AND amount > 0")})
    end
  end

  context 'parsing .first' do
    it 'as a model method with no arguments' do
      finder = %Q{MyModel.first}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.first})
    end

    it 'as a model method' do
      finder = %Q{MyModel.first(:joins => [:payment_method], :conditions => ["payment_methodable_type = 'ChequePaymentMethod' AND amount > 0"])}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.joins(:payment_method).where("payment_methodable_type = 'ChequePaymentMethod' AND amount > 0").first})
    end

    it 'as a chained method' do
      finder = %Q{self.payments.first(:joins => [:payment_method], :conditions => ["payment_methodable_type = 'ChequePaymentMethod' AND amount > 0"])}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.payments.joins(:payment_method).where("payment_methodable_type = 'ChequePaymentMethod' AND amount > 0").first})
    end

    it '' do
      finder = %Q{MyModel.first(:conditions=> conditions_array, :order => "tickets.weight desc, tickets.sort_date asc", :include => INCLUDE, :joins => joins)}
      expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.where(conditions_array).order("tickets.weight desc, tickets.sort_date asc").includes(INCLUDE).joins(joins).first})
    end
  end


  context 'parsing #find' do

    context 'with the :first argument' do

      it 'without conditions in a model' do
        finder = %Q{MyModel.find(:first)}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.first})
      end

      it 'without conditions in a model - leading whitespace' do
        finder = %Q{MyModel.find(:first)}.prepend("  ")
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.first}.prepend("  "))
      end

      it 'without conditions in a model' do
        finder = %Q{MyModel.find(:first, :order => 'created_at DESC', :conditions => "active = 1")}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.order("created_at DESC").where("active = 1").first})
      end

      it 'with hash conditions in a model' do
        finder = %Q{MyModel.find(:first, :order => 'created_at DESC', :conditions => {:active => 1})}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{MyModel.order("created_at DESC").where(active: 1).first})
      end

      it 'without conditions' do
        finder = %Q{self.payment_optimizations.find(:first)}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.payment_optimizations.first})
      end

      it 'with a single condition' do 
        finder = %Q{self.payment_optimizations.find(:first, :order => 'created_at DESC')}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.payment_optimizations.order("created_at DESC").first})
      end

      it 'with conditions' do
        finder = %Q{self.payment_optimizations.find(:first, :order => 'created_at DESC', :conditions => "active = 1")}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.payment_optimizations.order("created_at DESC").where("active = 1").first})
      end

    end

    context 'with the :all argument' do
      it 'should not append .all' do
        finder = %Q{self.find(:all, :select => "DISTINCT(sales_channels.name)").map(&:name)}
        expect(ArelConverter::Translator::Finder.translate(finder)).to eq(%Q{self.select("DISTINCT(sales_channels.name)").map(&:name)})
      end
    end

  end

end



