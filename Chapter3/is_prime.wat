(module
	;; add the $even_check function to the top of the module
	(func $even_check (param $n i32) (result i32)
		local.get $n
		i32.const 2
		i32.rem_u ;; if you take the remainder of a division by 2
		i32.const 0 ;; even numbers will have a remainder 0
		i32.eq ;; $n % 2 == 0
	)
	;; add the $eq_2 function after $even_check
	(func $eq_2 (param $n i32) (result i32)
		local.get $n
		i32.const 2
		i32.eq ;; returns 1 if $n == 2
	)

	;; add $multiple_check after $eq_2
	(func $multiple_check (param $n i32) (param $m i32) (result i32)
		local.get $n
		local.get $m
		i32.rem_u ;; get the remainder of $n / $m
		i32.const 0 ;; I want to know if the remainder is 0
		i32.eq ;; that will tell us if $n is a multiple of $m
	)	

	;; add the is_prime exported function after $multiple_check
	(func (export "is_prime") (param $n i32) (result i32)
		(local $i i32)
		(if (i32.eq (local.get $n) (i32.const 1)) ;; 1 is not prime
		(then
			i32.const 0
			return
		))
		(if (call $eq_2 (local.get $n)) ;; check to see if $n is 2
		(then
			i32.const 1 ;; 2 is prime
			return
		)
	)
	(block $not_prime
		(call $even_check (local.get $n))
		br_if $not_prime ;; even numbers are not prime (except 2)

		(local.set $i (i32.const 1))
		(loop $prime_test_loop

			(local.tee $i (i32.add (local.get $i) (i32.const 2) ) ) ;; $i += 2
			local.get $n ;; stack = [$n, $i]
 
			i32.ge_u ;; $i >= $n
			if ;; if $i >= $n, $n is prime
				i32.const 1
			return
			end
			(call $multiple_check (local.get $n) (local.get $i))
			br_if $not_prime ;; if $n is a multiple of $i this is not prime
			br $prime_test_loop ;; branch back to top of loop
			) ;; end of $prime_test_loop loop
		) ;; end of $not_prime block

i32.const 0 ;; return false
 )
) ;; end of module