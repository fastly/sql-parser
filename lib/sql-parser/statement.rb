module SQLParser

  module Statement

    class Node

      def accept(visitor)
        klass = self.class.ancestors.find do |ancestor|
          visitor.respond_to?("visit_#{demodulize(ancestor.name)}")
        end

        if klass
          visitor.__send__("visit_#{demodulize(klass.name)}", self)
        else
          raise "No visitor for #{self.class.name}"
        end
      end

      def to_sql
        SQLVisitor.new.visit(self)
      end

      private

      def demodulize(str)
        str.split('::')[-1]
      end
    end

    class Query < Node
      def initialize(select_clause, from_clause, using_scope_clause = nil, where_clause = nil, group_by_clause = nil, having_clause = nil, order_by_clause = nil, limit_clause = nil)
        @select_clause = select_clause
        @from_clause = from_clause
        @using_scope_clause = using_scope_clause
        @where_clause = where_clause
        @group_by_clause = group_by_clause
        @having_clause = having_clause
        @order_by_clause = order_by_clause
        @limit_clause = limit_clause
      end

      attr_accessor :select_clause
      attr_accessor :from_clause
      attr_accessor :using_scope_clause
      attr_accessor :where_clause
      attr_accessor :group_by_clause
      attr_accessor :having_clause
      attr_accessor :order_by_clause
      attr_accessor :limit_clause

    end

    class OrderBy < Node

      def initialize(sort_specification)
        @sort_specification = Array(sort_specification)
      end

      attr_accessor :sort_specification

    end

    class Subquery < Node

      def initialize(query_specification)
        @query_specification = query_specification
      end

      attr_accessor :query_specification

    end

    class Select < Node
      def initialize(list)
        @list = list
      end

      attr_accessor :list
    end

    class SelectList < Node

      def initialize(columns)
        @columns = Array(columns)
      end

      attr_accessor :columns

    end

    class Distinct < Node

      def initialize(column)
        @column = column
      end

      attr_accessor :column

    end

    class FromClause < Node

      def initialize(tables)
        @tables = Array(tables)
      end

      attr_accessor :tables

    end

    class UsingScope < Node
      def initialize(scope)
        @scope = scope
      end

      attr_accessor :scope
    end

    class OrderClause < Node

      def initialize(columns)
        @columns = Array(columns)
      end

      attr_accessor :columns

    end

    class OrderColumn < Node

      def initialize(column, order = nil, nulls_order = nil)
        @column = column
        @order = order
        @nulls_order = nulls_order
      end

      attr_accessor :column
      attr_accessor :order
      attr_accessor :nulls_order

    end

    class Ascending < Node
    end

    class Descending < Node
    end

    class NullsFirst < Node
    end

    class NullsLast < Node
    end

    class HavingClause < Node

      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_accessor :search_condition

    end

    class GroupByClause < Node

      def initialize(columns)
        @columns = Array(columns)
      end

      attr_accessor :columns

    end

    class WhereClause < Node

      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_accessor :search_condition

    end

    class LimitClause < Node

      def initialize(limit)
        @limit = limit
      end

      attr_accessor :limit

    end

    class On < Node

      def initialize(search_condition)
        @search_condition = search_condition
      end

      attr_accessor :search_condition

    end

    class SearchCondition < Node

      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_accessor :left
      attr_accessor :right

    end

    class Using < Node

      def initialize(columns)
        @columns = Array(columns)
      end

      attr_accessor :columns

    end

    class Or < SearchCondition
    end

    class And < SearchCondition
    end

    class Exists < Node

      def initialize(table_subquery)
        @table_subquery = table_subquery
      end

      attr_accessor :table_subquery

    end

    class ComparisonPredicate < Node

      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_accessor :left
      attr_accessor :right

    end

    class Is < ComparisonPredicate
    end

    class Like < ComparisonPredicate
    end

    class In < ComparisonPredicate
    end

    class InValueList < Node

      def initialize(values)
        @values = values
      end

      attr_accessor :values

    end

    class Between < Node

      def initialize(left, min, max)
        @left = left
        @min = min
        @max = max
      end

      attr_accessor :left
      attr_accessor :min
      attr_accessor :max

    end

    class GreaterOrEquals < ComparisonPredicate
    end

    class LessOrEquals < ComparisonPredicate
    end

    class Greater < ComparisonPredicate
    end

    class Less < ComparisonPredicate
    end

    class Equals < ComparisonPredicate
    end

    class Aggregate < Node

      def initialize(column)
        @column = column
      end

      attr_accessor :column

    end

    class Sum < Aggregate
    end

    class Minimum < Aggregate
    end

    class Maximum < Aggregate
    end

    class Average < Aggregate
    end

    class Count < Aggregate
    end

    class Function < Node
      def initialize(function, arguments)
        @function = function
        @arguments = arguments
      end

      attr_accessor :function
      attr_accessor :arguments
    end

    class QualifiedColumn < Node

      def initialize(table, column)
        @table = table
        @column = column
      end

      attr_accessor :table
      attr_accessor :column

    end

    class Identifier < Node

      def initialize(name)
        @name = name
      end

      attr_accessor :name

    end

    class Table < Identifier
      def initialize(*names)
        @names = names
      end

      attr_accessor :names
    end

    class Column < Identifier
    end

    class As < Node

      def initialize(value, column)
        @value = value
        @column = column
      end

      attr_accessor :value
      attr_accessor :column

    end

    class Arithmetic < Node

      def initialize(left, right)
        @left = left
        @right = right
      end

      attr_accessor :left
      attr_accessor :right

    end

    class Multiply < Arithmetic
    end

    class Divide < Arithmetic
    end

    class Add < Arithmetic
    end

    class Subtract < Arithmetic
    end

    class Unary < Node

      def initialize(value)
        @value = value
      end

      attr_accessor :value

    end

    class Not < Unary
    end

    class UnaryPlus < Unary
    end

    class UnaryMinus < Unary
    end

    class True < Node
    end

    class False < Node
    end

    class Null < Node
    end

    class Literal < Node

      def initialize(value)
        @value = value
      end

      attr_accessor :value

    end

    class DateTime < Literal
    end

    class Date < Literal
    end

    class DateLiteral < Node
      def initialize(literal, arg = nil)
        @literal = literal
        @arg = arg
      end

      attr_accessor :literal
      attr_accessor :arg
    end

    class String < Literal
    end

    class ApproximateFloat < Node

      def initialize(mantissa, exponent)
        @mantissa = mantissa
        @exponent = exponent
      end

      attr_accessor :mantissa
      attr_accessor :exponent

    end

    class Float < Literal
    end

    class Integer < Literal
    end

  end
end
