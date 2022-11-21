

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "semant.h"
#include "utilities.h"

extern int semant_debug;
extern char *curr_filename;

//////////////////////////////////////////////////////////////////////
//
// Symbols
//
// For convenience, a large number of symbols are predefined here.
// These symbols include the primitive type and method names, as well
// as fixed names used by the runtime system.
//
//////////////////////////////////////////////////////////////////////
static Symbol 
	arg,
	arg2,
	Bool,
	concat,
	cool_abort,
	copy,
	Int,
	in_int,
	in_string,
	IO,
	length,
	Main,
	main_meth,
	No_class,
	No_type,
	Object,
	out_int,
	out_string,
	prim_slot,
	self,
	SELF_TYPE,
	Str,
	str_field,
	substr,
	type_name,
	val;
//
// Initializing the predefined symbols.
//

static void initialize_constants(void)
{
	arg         = idtable.add_string("arg");
	arg2        = idtable.add_string("arg2");
	Bool        = idtable.add_string("Bool");
	concat      = idtable.add_string("concat");
	cool_abort  = idtable.add_string("abort");
	copy        = idtable.add_string("copy");
	Int         = idtable.add_string("Int");
	in_int      = idtable.add_string("in_int");
	in_string   = idtable.add_string("in_string");
	IO          = idtable.add_string("IO");
	length      = idtable.add_string("length");
	Main        = idtable.add_string("Main");
	main_meth   = idtable.add_string("main");
	//   _no_class is a symbol that can't be the name of any 
	//   user-defined class.
	No_class    = idtable.add_string("_no_class");
	No_type     = idtable.add_string("_no_type");
	Object      = idtable.add_string("Object");
	out_int     = idtable.add_string("out_int");
	out_string  = idtable.add_string("out_string");
	prim_slot   = idtable.add_string("_prim_slot");
	self        = idtable.add_string("self");
	SELF_TYPE   = idtable.add_string("SELF_TYPE");
	Str         = idtable.add_string("String");
	str_field   = idtable.add_string("_str_field");
	substr      = idtable.add_string("substr");
	type_name   = idtable.add_string("type_name");
	val         = idtable.add_string("_val");
}

bool is_basic_type(Symbol class_name) {
	if (class_name == Object or class_name == Int or class_name == IO or
			class_name == Str or class_name == Bool or class_name == SELF_TYPE)
		return true;
	return false;
}

bool ClassTable::is_subtype(Symbol child, Symbol parent) {
    if (parent == child or parent == Object or child == No_type ){
        return true;
    }
	if (child == No_type) {
		return true;
	}

    while (child != No_class) {
        class_node node = static_cast<class_node>(class_symbol_table.lookup(child));
        if (node == NULL){
            return false;
        }
        child = node->get_parent();
        if (child == parent){
            return true;
        }
    }
    return false;
}

Symbol ClassTable::get_feature_type(Feature feature) {
	if (dynamic_cast<attr_class*>(feature) != NULL) {
		attr_class* ptr = static_cast<attr_class*>(feature);
		return ptr->get_decl_type();
	}
	else if (dynamic_cast<method_class*>(feature) != NULL) {
		method_class* ptr = static_cast<method_class*>(feature);
		return ptr->get_return_type();
	}
	return No_type;
}

Symbol ClassTable::lca(Symbol a, Symbol b) {
	if (is_subtype(a, b)) return b;
	else if (is_subtype(b, a)) return a;

	Symbol parent = static_cast<class_node>(class_symbol_table.lookup(a))->get_parent();
	return lca(parent, b);
}

ClassTable::ClassTable(Classes classes) : semant_errors(0) , error_stream(cerr) {
	class_symbol_table.enterscope();
	install_basic_classes();

	Symbol class_name;
	class_node current_class; 


	/** First pass:
	 * 1) create class symbol table
	 * 2) check for redifinition.
	 */
	for (int i = classes->first(); classes->more(i); i = classes->next(i)) {

		current_class = static_cast<class_node>(classes->nth(i));
		class_name = current_class->get_name();

		// Basic types redifinition !!
		if (is_basic_type(class_name)) {
			ostream& output_error_stream =  semant_error(current_class);
			output_error_stream << "Redifinition of basic class "<<class_name<<"."<<endl;
			continue;
		}

		// User-defined types redifinition !!
		else if (class_symbol_table.lookup(class_name) != NULL) {
			//  check the situation of class multiply defined. 
			ostream& output_error_stream =  semant_error(current_class);
			output_error_stream << "Class " << class_name << " was previously defined." << endl;
			continue;
		} 

		// Valid type definition.
		class_symbol_table.addid(class_name, current_class);
	}

	/** Second pass:
	 * 1) check class hiarchy.
	 * 2) check decleared types.
	 * 3) complete feature table.
	 */
	for ( int i = classes->first(); classes->more(i); i = classes->next(i) ){
        current_class = static_cast<class_node>(classes->nth(i));
        check_class_hiarchy(current_class);
    }

	// Check Main class and method.
	if (class_symbol_table.lookup(Main) == NULL) {
		ostream& output_error_stream =  semant_error(current_class);
		output_error_stream<<"Class \"Main\" is not defined."<<endl;
	}
	else {
		// Main class is defined.
		class_node main_class = static_cast<class_node>(class_symbol_table.probe(Main));
		Table main_class_table = main_class->feature_table;
		if (main_class_table.probe(main_meth) == NULL) {
			ostream& output_error_stream =  semant_error(current_class);
			output_error_stream<<"Method \"main\" is not defined."<<endl;
		}
	}

	/** Third pass:
	 * 1) Type check expressions.
	 */
	for ( int i = classes->first(); classes->more(i); i = classes->next(i) ){
        current_class = static_cast<class_node>(classes->nth(i));
        check_class_expr(current_class);
    }
}

void ClassTable::check_class_hiarchy(class_node current_class) {
	Table current_table = current_class->feature_table;
	
	// New scope.
	current_table.enterscope();

	Symbol& class_name = current_class->get_name();
	
	if (class_name !=  Object) {
		Symbol& parent_name = current_class->get_parent();
		if (parent_name == SELF_TYPE) {
			ostream& output_error_stream =  semant_error(current_class);
			output_error_stream<<"Class "<<class_name<<" cannot inherit from "<<parent_name<<endl;
		}
		if (class_symbol_table.lookup(parent_name) == NULL) {
			ostream& output_error_stream =  semant_error(current_class);
			output_error_stream<<"Class "<<class_name<<" inherits from undecleared class: "<<parent_name<<endl;
		}
	}

	Features& features = current_class->get_features();

	for(int i = features->first(); features->more(i); i = features->next(i)) {
		Feature feature = features->nth(i);
		if (dynamic_cast<attr_class*>(feature) != NULL) {
			check_class_attr(current_class, static_cast<attr_class*>(feature));
		}
		else if ( dynamic_cast<method_class*>(feature) != NULL) {
			check_class_method(current_class, static_cast<method_class*>(feature));
		}
	}
}

void ClassTable::check_class_attr(class_node current_class, attr_class* attr) {
	Symbol attr_name = attr->get_name();
	Table current_table = current_class->feature_table;
	// Note that no new scope is required.

	Symbol attr_type = attr->get_decl_type();

	if (attr_name == self) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<" \"self\" is not valid name for class attribute."<<endl;
	}

	if (class_symbol_table.lookup(attr_type) == NULL) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Decleared type "<<attr_type<<" for attribute "<<attr_name<<" is not defined."<<endl;
	}

	if (current_table.probe(attr_name)) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Attribute "<<attr_name<<" is priviously defined."<<endl;
	}

	current_table.addid(attr_name, attr);
}

void ClassTable::check_class_method(class_node current_class, method_class* method) {
	Symbol method_name = method->get_name();
	Table current_table = current_class->feature_table;

	Symbol& method_return_type = method->get_return_type();

	if (class_symbol_table.lookup(method_return_type) == NULL) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Decleared return type for method "<<method_name<<" is not defined."<<endl;
	}

	if (current_table.probe(method_name) != NULL) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Method "<<method_name<<" is priviously defined in this scope."<<endl;
	}

	current_table.addid(method_name, method);
}

void ClassTable::check_class_expr(class_node current_class) {
	Table current_table = current_class->feature_table;

	Symbol class_name = current_class->get_name();
	Features& class_features = current_class->get_features();

	 for (int i = class_features->first(); class_features->more(i); i = class_features->next(i)) {
        Feature feature = class_features->nth(i);
        if (dynamic_cast<attr_class*>(feature) != NULL) {
            check_attr_expr(current_class, static_cast<attr_class*>(feature));         
        }
        else if (dynamic_cast<method_class*>(feature) != NULL) {
            check_method_expr(current_class, (method_class*)feature);
        }
    } 
}

// initializer expression type checker
void ClassTable::check_attr_expr(class_node current_class, attr_class* attr) {
	Symbol attr_name = attr->get_name();
	Table current_table = current_class->feature_table;
	Symbol attr_type = attr->get_decl_type();

	Expression& init_expr = attr->get_init_expr();

	check_expr(current_class, init_expr);

	if (!is_subtype(init_expr->type, attr_type)) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Initialization expression has incompatible static type for attribute "<<attr_name<<endl;
	}
}

// function type cheker
void ClassTable::check_method_expr(class_node current_class, method_class* method) {
	Symbol method_name = method->get_name();
	Symbol method_return_type = method->get_return_type();
	Formals& method_formals = method->get_formals();
	Expression& method_expr = method->get_expr();

	Table current_table = current_class->feature_table;
	current_table.enterscope();

	for (int i = method_formals->first(); method_formals->more(i); i = method_formals->next(i)) {
		Formal formal = method_formals->nth(i);
		check_formal_expr(current_class, static_cast<formal_class*>(formal));
	}

	check_expr(current_class, method_expr);

	current_table.exitscope();

	if (!is_subtype(method_expr->type, method_return_type)) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Method body expression has incompatible static type for Method "<<method_name<<" decleared return type."<<endl;
	}
}

void ClassTable::check_formal_expr(class_node current_class, formal_class* formal) {
	Table current_table = current_class->feature_table;
	Symbol formal_name = formal->get_name();
	Symbol formal_type = formal->get_decl_type();

	if (formal_name == self) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Cannot use \""<<formal_name<<"\" as formal parameter."<<endl;
	}

	if (formal_type == SELF_TYPE) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Formal parameter "<<formal_name<<" has invalid type "<<formal_type<<" for formal parameter."<<endl;
	}

	else if (class_symbol_table.lookup(formal_type) == NULL) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Undefined type "<<formal_type<<" for formal parameter "<<formal_name<<endl;
	}

	if (current_table.probe(formal_name)) {
		ostream& output_error_stream = semant_error(current_class);
		output_error_stream<<"Formal parameter name: "<<formal_name<<" priviously used."<<endl;
	}

	current_table.addid(formal_name, formal);
}

void ClassTable::check_expr(class_node current_class, Expression_class* expr) {
	Table current_table = current_class->feature_table;

	// initial type is No_type;
	//	Semantical analyzer will continue its task after seeing errors.
	expr->type = No_type;

	// Assign
	if (dynamic_cast<assign_class*>(expr) != NULL) {
		assign_class* expr_ptr = static_cast<assign_class*>(expr);
		Feature feature = static_cast<Feature>(current_table.lookup(expr_ptr->name));
		if (feature == NULL) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Variable "<<expr_ptr->name<<" is not decleared."<<endl;
		}
		else if (dynamic_cast<attr_class*>(feature) == NULL) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Variable "<<expr_ptr->name<<" is not decleared."<<endl;
		}

		else {
			check_expr(current_class, expr_ptr->expr);
			if (!is_subtype(expr_ptr->expr->type, get_feature_type(feature))) {
				ostream& output_error_stream = semant_error(current_class);
				output_error_stream<<"Expression type is not compatible with variable "<<expr_ptr->name<<endl;
			}
			else {
				expr->type = expr_ptr->expr->type;
			}
		}
	}

	// Static dispatch
	else if (dynamic_cast<static_dispatch_class*>(expr) != NULL) {
		static_dispatch_class* ptr = static_cast<static_dispatch_class*>(expr);

		check_expr(current_class, ptr->expr);

		if (ptr->type_name == SELF_TYPE) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Static dispatch cannot be called on "<<SELF_TYPE<<endl;
		}
		else if (class_symbol_table.lookup(ptr->type_name) == NULL) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<ptr->type_name<<" is not a decleared class"<<endl;
		}
		if (!is_subtype(ptr->expr->type, ptr->type_name)) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Callee expression is not compatible with class "<<ptr->type_name<<endl;
		}

		Table class_feature_table = static_cast<class_node>(class_symbol_table.lookup(ptr->type_name))->feature_table;
		if (class_feature_table.probe(ptr->name) == NULL) {
			// Class doesnt have the called function.
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Class "<<ptr->type_name<<" does'nt have feature "<<ptr->name<<endl;
		}
		else {
			Feature feature = static_cast<Feature_class*>(class_feature_table.probe(ptr->name));
			if (dynamic_cast<method_class*>(feature) != NULL) {
				method_class* method_ptr = static_cast<method_class*>(feature);

				// check number of arguments.
				if (ptr->actual->len() != method_ptr->get_formals()->len()) {
					ostream& output_error_stream = semant_error(current_class);
					output_error_stream<<"Method "<<ptr->name<<" in class "<<ptr->type_name<<" requires "<<method_ptr->get_formals()->len()<<" arguments, "
					<<ptr->actual->len()<<" was given."<<endl;
				}

				// check each arguments type.
				for (int i = ptr->actual->first(), j = method_ptr->get_formals()->first(); (ptr->actual->more(i) and method_ptr->get_formals()->more(j));
						 i = ptr->actual->next(i), j = method_ptr->get_formals()->next(j)) {
					Expression actual_expr = static_cast<Expression_class*>(ptr->actual->nth(i));
					formal_class* formal = static_cast<formal_class*>(method_ptr->get_formals()->nth(j));
					check_expr(current_class, actual_expr);
					if (!is_subtype(actual_expr->type, formal->get_decl_type())) {
						ostream& output_error_stream = semant_error(current_class);
						output_error_stream<<"Argument "<<i<<" does'nt conform to requirments by method "<<ptr->name<<endl;
					}
				}

				if (method_ptr->get_return_type() == SELF_TYPE) {
					expr->type = ptr->expr->type;
				}
				else {
					expr->type = method_ptr->get_return_type();
				}
			}
			else {
				ostream& output_error_stream = semant_error(current_class);
				output_error_stream<<"Class "<<ptr->type_name<<" does'nt have method "<<ptr->name<<endl;
			}
		}
	}

	// Dispatch
	else if (dynamic_cast<dispatch_class*>(expr) != NULL) {
		dispatch_class* ptr = static_cast<dispatch_class*>(expr);

		check_expr(current_class, ptr->expr);

		Symbol type_name = ptr->expr->type;
		if (ptr->expr->type == SELF_TYPE) {
			type_name = current_class->get_name();
		}
		Table class_feature_table = static_cast<class_node>(class_symbol_table.lookup(type_name))->feature_table;
		if (class_feature_table.probe(ptr->name) == NULL) {
			// Class doesnt have the called function.
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Class "<<type_name<<" does not have feature "<<ptr->name<<endl;
		}

		else {
			Feature feature = static_cast<Feature_class*>(class_feature_table.probe(ptr->name));
			if (dynamic_cast<method_class*>(feature) != NULL) {
				method_class* method_ptr = static_cast<method_class*>(feature);

				// check number of arguments.
				if (ptr->actual->len() != method_ptr->get_formals()->len()) {
					ostream& output_error_stream = semant_error(current_class);
					output_error_stream<<"Method "<<ptr->name<<" in class "<<type_name<<" requires "<<method_ptr->get_formals()->len()<<" arguments, "
					<<ptr->actual->len()<<" was given."<<endl;
				}

				// check each arguments type.
				for (int i = ptr->actual->first(), j = method_ptr->get_formals()->first(); (ptr->actual->more(i) and method_ptr->get_formals()->more(j));
						i = ptr->actual->next(i), j = method_ptr->get_formals()->next(j)) {
					Expression actual_expr = static_cast<Expression_class*>(ptr->actual->nth(i));
					formal_class* formal = static_cast<formal_class*>(method_ptr->get_formals()->nth(j));
					check_expr(current_class, actual_expr);
					if (!is_subtype(actual_expr->type, formal->get_decl_type())) {
						ostream& output_error_stream = semant_error(current_class);
						output_error_stream<<"Argument "<<i<<" does'nt conform to requirments by method "<<ptr->name<<endl;
					}
				}

				if (method_ptr->get_return_type() == SELF_TYPE) {
					expr->type = ptr->expr->type;
				}
				else {
					expr->type = method_ptr->get_return_type();
				}
			}
			else {
				ostream& output_error_stream = semant_error(current_class);
				output_error_stream<<"Class "<<type_name<<" does'nt have method "<<ptr->name<<endl;
			}
		}
	}

	// Block
	else if (dynamic_cast<block_class*>(expr) != NULL) {
		block_class* ptr = static_cast<block_class*>(expr);

		for (int i = ptr->body->first(); ptr->body->more(i); i = ptr->body->next(i)) {
			Expression current_expr = ptr->body->nth(i);
			check_expr(current_class, current_expr);
			expr->type = current_expr->type;
		}
	}

	// Conditional
	else if (dynamic_cast<cond_class*>(expr) != NULL) {
		cond_class* ptr = static_cast<cond_class*>(expr);

		check_expr(current_class, ptr->pred);
		if (ptr->pred->type != Bool) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Predicate of type "<<ptr->pred->type<<" does not conform to type Bool."<<endl;
		}

		check_expr(current_class, ptr->then_exp);
		check_expr(current_class, ptr->else_exp);

		expr->type = lca(ptr->then_exp->type, ptr->else_exp->type);
		if (class_symbol_table.lookup(expr->type) == NULL) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Conditional expressions are not compatible."<<endl;
		}
	}

	// Loop
	else if (dynamic_cast<loop_class*>(expr) != NULL) {
		loop_class* ptr = static_cast<loop_class*>(expr);

		check_expr(current_class, ptr->pred);
		if (ptr->pred->type != Bool) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Predicate of type "<<ptr->pred->type<<" does not conform to type Bool."<<endl;
		}
		expr->type = Object;
	}

	// Case
	else if (dynamic_cast<typcase_class*>(expr) != NULL) {
		typcase_class* ptr = static_cast<typcase_class*>(expr);
		Table current_table = current_class->feature_table;

		check_expr(current_class, ptr->expr);

		Symbol type = NULL;

		for (int i = ptr->cases->first(); ptr->cases->more(i); i = ptr->cases->next(i)) {
			branch_class* branch = static_cast<branch_class*>(ptr->cases->nth(i));

			// Insert variable into table.
			current_table.enterscope();
			attr_class current_attr_store = *new attr_class(branch->get_name(), branch->get_decl_type(), no_expr());
			attr_class* current_attr = &current_attr_store;
			current_table.addid(branch->get_name(), current_attr);

			check_expr(current_class, branch->get_expr());
			if (type == NULL) {
				type = branch->get_expr()->type;
			}
			else {
				type = lca(type, branch->get_expr()->type);
			}

			// Erase variable from table.
			current_table.exitscope();
			delete current_attr;
		}
		expr->type = type;
	}

	// Let
	else if (dynamic_cast<let_class*>(expr)) {
		let_class* ptr = static_cast<let_class*>(expr);
		Table current_table = current_class->feature_table;

		Symbol type_name = ptr->type_decl;
		if (type_name == SELF_TYPE) {
			type_name = current_class->get_name();
		}

		if (ptr->init != no_expr()) {
			check_expr(current_class, ptr->init);
			
			if (!is_subtype(ptr->init->type, type_name)) {
				ostream& output_error_stream = semant_error(current_class);
				output_error_stream<<"Initializer expression does not conform to type "<<ptr->type_decl<<" for identifier "<<ptr->identifier<<endl;
			}
		}

		// Insert variable into table.
		current_table.enterscope();
		attr_class current_attr_store = *new attr_class(ptr->identifier, ptr->type_decl, ptr->init);
		attr_class* current_attr = &current_attr_store;
		current_table.addid(ptr->identifier, current_attr);

		check_expr(current_class, ptr->body);
		expr->type = ptr->body->type;

		current_table.exitscope();
		delete current_attr;
	}

	// New
	else if (dynamic_cast<new__class*>(expr) != NULL) {
		new__class* ptr = static_cast<new__class*>(expr);
		expr->type = ptr->type_name;
		if (expr->type == SELF_TYPE) {
			expr->type = current_class->get_name();
		}
		else if (class_symbol_table.lookup(expr->type) == NULL) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<expr->type<<" is not a decleared type."<<endl;
		}
	}

	// Const Int
	else if (dynamic_cast<int_const_class*>(expr) != NULL) {
		// int_const_class* ptr = static_cast<int_const_class*>(expr);
		expr->type = Int;
	}

	else if (dynamic_cast<bool_const_class*>(expr) != NULL) {
		expr->type = Bool;
	}

	else if (dynamic_cast<string_const_class*>(expr) != NULL) {
		expr->type = Str;
	}

	else if (dynamic_cast<isvoid_class*>(expr) != NULL) {
		isvoid_class* ptr = static_cast<isvoid_class*>(expr);
		check_expr(current_class, ptr->e1);
		expr->type = Bool;
	}

	else if (dynamic_cast<no_expr_class*>(expr) != NULL) {
		expr->type = No_type;
	}

	// Single operand operators
	else if (dynamic_cast<neg_class*>(expr) != NULL) {
		neg_class* ptr = static_cast<neg_class*>(expr);
		check_expr(current_class, ptr->e1);
		if (ptr->e1->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Neg operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<comp_class*>(expr) != NULL) {
		comp_class* ptr = static_cast<comp_class*>(expr);
		check_expr(current_class, ptr->e1);
		if (ptr->e1->type != Bool) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"~ operator can only be applied to expressions of type Bool."<<endl;
		}
		else {
			expr->type = Bool;
		}
	}

	// Two operand operation
	else if (dynamic_cast<plus_class*>(expr) != NULL) {
		plus_class* ptr = static_cast<plus_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"+ operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<sub_class*>(expr) != NULL) {
		sub_class* ptr = static_cast<sub_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"- operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<mul_class*>(expr) != NULL) {
		mul_class* ptr = static_cast<mul_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"* operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}
	
	else if (dynamic_cast<divide_class*>(expr) != NULL) {
		divide_class* ptr = static_cast<divide_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"/ operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<lt_class*>(expr) != NULL) {
		lt_class* ptr = static_cast<lt_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"< operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<eq_class*>(expr) != NULL) {
		eq_class* ptr = static_cast<eq_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"= operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<leq_class*>(expr) != NULL) {
		leq_class* ptr = static_cast<leq_class*>(expr);
		check_expr(current_class, ptr->e1);
		check_expr(current_class, ptr->e2);
		if (ptr->e1->type != Int or ptr->e2->type != Int) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"<= operator can only be applied to expressions of type Int."<<endl;
		}
		else {
			expr->type = Int;
		}
	}

	else if (dynamic_cast<object_class*>(expr) != NULL) {
		object_class* ptr = static_cast<object_class*>(expr);
		Table current_table = current_class->feature_table;

		Feature feature = static_cast<Feature>(current_table.lookup(ptr->name));

		if (feature == NULL and ptr->name != self) {
			ostream& output_error_stream = semant_error(current_class);
			output_error_stream<<"Feature "<<ptr->name<<" is not defined."<<endl;
		}
		else {
			expr->type = get_feature_type(feature);
		}
	}
}

void ClassTable::install_basic_classes() {

	// The tree package uses these globals to annotate the classes built below.
   // curr_lineno  = 0;
	Symbol filename = stringtable.add_string("<basic class>");
	
	// The following demonstrates how to create dummy parse trees to
	// refer to basic Cool classes.  There's no need for method
	// bodies -- these are already built into the runtime system.
	
	// IMPORTANT: The results of the following expressions are
	// stored in local variables.  You will want to do something
	// with those variables at the end of this method to make this
	// code meaningful.

	// 
	// The Object class has no parent class. Its methods are
	//        abort() : Object    aborts the program
	//        type_name() : Str   returns a string representation of class name
	//        copy() : SELF_TYPE  returns a copy of the object
	//
	// There is no need for method bodies in the basic classes---these
	// are already built in to the runtime system.

	Class_ Object_class =
	class_(Object, 
		   No_class,
		   append_Features(
				   append_Features(
						   single_Features(method(cool_abort, nil_Formals(), Object, no_expr())),
						   single_Features(method(type_name, nil_Formals(), Str, no_expr()))),
				   single_Features(method(copy, nil_Formals(), SELF_TYPE, no_expr()))),
		   filename);

	// 
	// The IO class inherits from Object. Its methods are
	//        out_string(Str) : SELF_TYPE       writes a string to the output
	//        out_int(Int) : SELF_TYPE            "    an int    "  "     "
	//        in_string() : Str                 reads a string from the input
	//        in_int() : Int                      "   an int     "  "     "
	//
	Class_ IO_class = 
	class_(IO, 
		   Object,
		   append_Features(
				   append_Features(
						   append_Features(
								   single_Features(method(out_string, single_Formals(formal(arg, Str)),
											  SELF_TYPE, no_expr())),
								   single_Features(method(out_int, single_Formals(formal(arg, Int)),
											  SELF_TYPE, no_expr()))),
						   single_Features(method(in_string, nil_Formals(), Str, no_expr()))),
				   single_Features(method(in_int, nil_Formals(), Int, no_expr()))),
		   filename);  

	//
	// The Int class has no methods and only a single attribute, the
	// "val" for the integer. 
	//
	Class_ Int_class =
	class_(Int, 
		   Object,
		   single_Features(attr(val, prim_slot, no_expr())),
		   filename);

	//
	// Bool also has only the "val" slot.
	//
	Class_ Bool_class =
	class_(Bool, Object, single_Features(attr(val, prim_slot, no_expr())),filename);

	//
	// The class Str has a number of slots and operations:
	//       val                                  the length of the string
	//       str_field                            the string itself
	//       length() : Int                       returns length of the string
	//       concat(arg: Str) : Str               performs string concatenation
	//       substr(arg: Int, arg2: Int): Str     substring selection
	//       
	Class_ Str_class =
	class_(Str, 
		   Object,
		   append_Features(
				   append_Features(
						   append_Features(
								   append_Features(
										   single_Features(attr(val, Int, no_expr())),
										   single_Features(attr(str_field, prim_slot, no_expr()))),
								   single_Features(method(length, nil_Formals(), Int, no_expr()))),
						   single_Features(method(concat, 
									  single_Formals(formal(arg, Str)),
									  Str, 
									  no_expr()))),
				   single_Features(method(substr, 
							  append_Formals(single_Formals(formal(arg, Int)), 
									 single_Formals(formal(arg2, Int))),
							  Str, 
							  no_expr()))),
		   filename);

	class_symbol_table.addid(Object,(class__class*)Object_class); 
	class_symbol_table.addid(IO,(class__class*)IO_class); 
	class_symbol_table.addid(Int,(class__class*)Int_class); 
	class_symbol_table.addid(Bool,(class__class*)Bool_class); 
	class_symbol_table.addid(Str,(class__class*)Str_class); 
}

////////////////////////////////////////////////////////////////////
//
// semant_error is an overloaded function for reporting errors
// during semantic analysis.  There are three versions:
//
//    ostream& ClassTable::semant_error()                
//
//    ostream& ClassTable::semant_error(Class_ c)
//       print line number and filename for `c'
//
//    ostream& ClassTable::semant_error(Symbol filename, tree_node *t)  
//       print a line number and filename
//
///////////////////////////////////////////////////////////////////

ostream& ClassTable::semant_error(Class_ c)
{                                                             
	return semant_error(c->get_filename(),c);
}    

ostream& ClassTable::semant_error(Symbol filename, tree_node *t)
{
	error_stream << filename << ":" << t->get_line_number() << ": ";
	return semant_error();
}

ostream& ClassTable::semant_error()                  
{                                                 
	semant_errors++;                            
	return error_stream;
} 



/*   This is the entry point to the semantic checker.

	 Your checker should do the following two things:

	 1) Check that the program is semantically correct
	 2) Decorate the abstract syntax tree with type information
		by setting the `type' field in each Expression node.
		(see `tree.h')

	 You are free to first do 1), make sure you catch all semantic
	 errors. Part 2) can be done in a second stage, when you want
	 to build mycoolc.
 */
void program_class::semant()
{
	initialize_constants();

	/* ClassTable constructor may do some semantic analysis */
	ClassTable *classtable = new ClassTable(classes);

	/* some semantic analysis code may go here */

	if (classtable->errors()) {
		cerr << "Compilation halted due to static semantic errors." << endl;
		exit(1);
	}
}


