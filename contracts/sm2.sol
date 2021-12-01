// SPDX-License-Identifier: MIT
// version: 0.1

pragma solidity ^0.8.9;

library SM2Curve {

	event Log(string, uint);

	uint constant SM2_P = 0xfffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;
	uint constant SM2_A = 0xfffffffeffffffffffffffffffffffffffffffff00000000fffffffffffffffc;
	uint constant SM2_B = 0x28e9fa9e9d9f5e344d5a9e4bcf6509a7f39789f515ab8f92ddbcbd414d940e93;
	uint constant SM2_X = 0x32c4ae2c1f1981195f9904466a39c9948fe30bbff2660be1715a4589334c74c7;
	uint constant SM2_Y = 0xbc3736a2f4f6779c59bdcee36b692153d0a9877cc62a474002df32e52139f0a0;
	uint constant SM2_N = 0xfffffffeffffffffffffffffffffffff7203df6b21c6052b53bbf40939d54123;
	uint constant SM2_U = (SM2_P - 3)/4 + 1;

	function submod(uint a, uint b, uint p) internal pure returns (uint) {
		if (a >= b) {
			return a - b;
		} else {
			return ((p - b) + a);
		}
	}

	// a/2 == (a + p)/2 == (a + 1)/2 + (p - 1)/2
	// FIXME: change add() formula with out div2 operation
	function div2mod(uint a, uint p) internal pure returns (uint) {
		if (a % 2 == 0) {
			return a/2;
		} else {
			return ((a + 1)/2) + (p - 1)/2;
		}
	}

	function expmod(uint a, uint e, uint m) internal pure returns (uint) {
		uint r = 1;
		while (e > 0) {
			if (e & 1 == 1) {
				r = mulmod(r, a, m);
			}
			a = mulmod(a, a, m);
			e >>= 1;
		}
		return r;
	}

	function invmod(uint a, uint p) internal pure returns (uint) {
		return expmod(a, p-2, p);
	}

	function invmodp(uint a) internal pure returns (uint) {
		uint r;
		uint a1;
		uint a2;
		uint a3;
		uint a4;
		uint a5;
		int i;

		a1 = mulmod(a, a, SM2_P);
		a2 = mulmod(a1, a, SM2_P);
		a3 = mulmod(a2, a2, SM2_P);
		a3 = mulmod(a3, a3, SM2_P);
		a3 = mulmod(a3, a2, SM2_P);
		a4 = mulmod(a3, a3, SM2_P);
		a4 = mulmod(a4, a4, SM2_P);
		a4 = mulmod(a4, a4, SM2_P);
		a4 = mulmod(a4, a4, SM2_P);
		a4 = mulmod(a4, a3, SM2_P);
		a5 = mulmod(a4, a4, SM2_P);
		for (i = 1; i < 8; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a4, SM2_P);
		for (i = 0; i < 8; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a4, SM2_P);
		for (i = 0; i < 4; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a3, SM2_P);
		a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a2, SM2_P);
		a5 = mulmod(a5, a5, SM2_P);
		a5 = mulmod(a5, a, SM2_P);
		a4 = mulmod(a5, a5, SM2_P);
		a3 = mulmod(a4, a1, SM2_P);
		a5 = mulmod(a4, a4, SM2_P);
		for (i = 1; i< 31; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a4 = mulmod(a5, a4, SM2_P);
		a4 = mulmod(a4, a4, SM2_P);
		a4 = mulmod(a4, a, SM2_P);
		a3 = mulmod(a4, a2, SM2_P);
		for (i = 0; i < 33; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a2 = mulmod(a5, a3, SM2_P);
		a3 = mulmod(a2, a3, SM2_P);
		for (i = 0; i < 32; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a2 = mulmod(a5, a3, SM2_P);
		a3 = mulmod(a2, a3, SM2_P);
		a4 = mulmod(a2, a4, SM2_P);
		for (i = 0; i < 32; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a2 = mulmod(a5, a3, SM2_P);
		a3 = mulmod(a2, a3, SM2_P);
		a4 = mulmod(a2, a4, SM2_P);
		for (i = 0; i < 32; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a2 = mulmod(a5, a3, SM2_P);
		a3 = mulmod(a2, a3, SM2_P);
		a4 = mulmod(a2, a4, SM2_P);
		for (i = 0; i < 32; i++)
			a5 = mulmod(a5, a5, SM2_P);
		a2 = mulmod(a5, a3, SM2_P);
		a3 = mulmod(a2, a3, SM2_P);
		a4 = mulmod(a2, a4, SM2_P);
		for (i = 0; i < 32; i++)
			a5 = mulmod(a5, a5, SM2_P);
		r = mulmod(a4, a5, SM2_P);

		return r;
	}

	struct SM2Point {
		uint X;
		uint Y;
		uint Z;
	}

	function isOnCurve(SM2Point memory P) public returns (bool) {
		uint t0;
		uint t1;
		uint t2;

		if (P.Z == 1) {
			t0 = mulmod(P.Y, P.Y, SM2_P);
			t1 = mulmod(P.X, 3, SM2_P);
			t0 = addmod(t0, t1, SM2_P);
			t1 = mulmod(P.X, P.X, SM2_P);
			t1 = mulmod(t1, P.X, SM2_P);
			t1 = addmod(t1, SM2_B, SM2_P);
		} else {
			t0 = mulmod(P.Y, P.Y, SM2_P);
			t1 = mulmod(P.Z, P.Z, SM2_P);
			t2 = mulmod(t1, t1, SM2_P);
			t1 = mulmod(t1, t2, SM2_P);
			t1 = mulmod(t1, SM2_B, SM2_P);
			t2 = mulmod(t2, P.X, SM2_P);
			t2 = mulmod(t2, 3, SM2_P);
			t0 = addmod(t0, t2, SM2_P);
			t2 = mulmod(P.X, P.X, SM2_P);
			t2 = mulmod(t2, P.X, SM2_P);
			t1 = addmod(t1, t2, SM2_P);
		}

		//emit Log("t0", t0);
		//emit Log("t1", t1);

		return (t0 == t1);
	}

	function neg(SM2Point memory P) public pure returns (SM2Point memory) {
		return SM2Point(P.X, SM2_P - P.Y, P.Z);
	}

	function dbl(SM2Point memory P) public returns (SM2Point memory) {
		uint X1 = P.X;
		uint Y1 = P.Y;
		uint Z1 = P.Z;

		//emit Log("X1", X1);

		uint T1;
		uint T2;
		uint T3;
		uint X3;
		uint Y3;
		uint Z3;

		T1 = mulmod(Z1, Z1, SM2_P);
		T2 = submod(X1, T1, SM2_P);	//emit Log("T2 = X1 - T1 = ", T2);
		T1 = addmod(X1, T1, SM2_P);	//emit Log("T1 = X1 + T1 = ", T1);
		T2 = mulmod(T2, T1, SM2_P);	//emit Log("T2 = T2 * T1 = ", T2);
		T2 = mulmod(3, T2, SM2_P);	//emit Log("T2 =  3 * T2 = ", T2);
		Y3 = addmod(Y1, Y1, SM2_P);	//emit Log("Y3 =  2 * Y1 = ", Y3);
		Z3 = mulmod(Y3, Z1, SM2_P);	//emit Log("Z3 = Y3 * Z1 = ", Z3);
		Y3 = mulmod(Y3, Y3, SM2_P);	//emit Log("Y3 = Y3^2    = ", Y3);
		T3 = mulmod(Y3, X1, SM2_P);	//emit Log("T3 = Y3 * X1 = ", T3);
		Y3 = mulmod(Y3, Y3, SM2_P);	//emit Log("Y3 = Y3^2    = ", Y3);
		Y3 = div2mod(Y3, SM2_P);	//emit Log("Y3 = Y3/2    = ", Y3);
		X3 = mulmod(T2, T2, SM2_P);	//emit Log("X3 = T2^2    = ", X3);
		T1 = addmod(T3, T3, SM2_P);	//emit Log("T1 =  2 * T1 = ", T1);
		X3 = submod(X3, T1, SM2_P);	//emit Log("X3 = X3 - T1 = ", X3);
		T1 = submod(T3, X3, SM2_P);	//emit Log("T1 = T3 - X3 = ", T1);
		T1 = mulmod(T1, T2, SM2_P);	//emit Log("T1 = T1 * T2 = ", T1);
		Y3 = submod(T1, Y3, SM2_P);	//emit Log("Y3 = T1 - Y3 = ", Y3);

		return SM2Point(X3, Y3, Z3);
	}

	function isAtInfinity(SM2Point memory P) public returns (bool) {
		//emit Log("Z1", P.Z);
		return (P.Z == 0);
	}

	function add(SM2Point memory P, SM2Point memory Q) public returns (SM2Point memory) {
		uint X1 = P.X;
		uint Y1 = P.Y;
		uint Z1 = P.Z;
		uint x2 = Q.X;
		uint y2 = Q.Y;

		uint T1;
		uint T2;
		uint T3;
		uint T4;
		uint X3;
		uint Y3;
		uint Z3;

		//emit Log("Z1", P.Z);

		if (isAtInfinity(Q)) {
			return P;
		}

		if (isAtInfinity(P)) {
			return Q;
		}

		assert(Q.Z == 1);

		T1 = mulmod(Z1, Z1, SM2_P);
		T2 = mulmod(T1, Z1, SM2_P);
		T1 = mulmod(T1, x2, SM2_P);
		T2 = mulmod(T2, y2, SM2_P);
		T1 = submod(T1, X1, SM2_P);
		T2 = submod(T2, Y1, SM2_P);
		if (T1 == 0) {
			if (T2 == 0) {
				return dbl(Q);
			} else {
				return SM2Point(1, 1, 0);
			}
		}
		Z3 = mulmod(Z1, T1, SM2_P);
		T3 = mulmod(T1, T1, SM2_P);
		T4 = mulmod(T3, T1, SM2_P);
		T3 = mulmod(T3, X1, SM2_P);
		T1 = addmod(T3, T3, SM2_P);
		X3 = mulmod(T2, T2, SM2_P);
		X3 = submod(X3, T1, SM2_P);
		X3 = submod(X3, T4, SM2_P);
		T3 = submod(T3, X3, SM2_P);
		T3 = mulmod(T3, T2, SM2_P);
		T4 = mulmod(T4, Y1, SM2_P);
		Y3 = submod(T3, T4, SM2_P);

		return SM2Point(X3, Y3, Z3);
	}

	function scalarMul(uint k, SM2Point memory P) public returns (SM2Point memory) {
		SM2Point memory Q = SM2Point(1, 1, 0);

		//emit Log("k", k);

		for (uint i = 0; i < 256; i++) {
			Q = dbl(Q);
			if ((k & 0x8000000000000000000000000000000000000000000000000000000000000000) > 0) {
				Q = add(Q, P);
			}
			k <<= 1;
		}
		return Q;
	}

	function scalarMulGenerator(uint k) public returns (SM2Point memory) {
		SM2Point memory G = SM2Point(SM2_X, SM2_Y, 1);
		return scalarMul(k, G);
	}


	/*
	 * sm2sign:
	 *	(x1, y1) = k*G
	 *	v = y1 mod 2
	 *	e = SM3(Z||M) in [0, 2^256-1]
	 *	r = (e + x1) mod n
	 *	s = (k - r*d) * (d + 1)^-1 (mod n)
	 *
	 * sm2recover:
	 *	d = (s + r)^-1 * (k - s) (mod n)
	 *	P = d*G = (s + r)^-1 * (k*G - s*G)
	 *		= (s + r)^-1 * (Q - s*G)
	 *		= -(s + r)^-1 * (s*G - Q)
	 *
	 * (x1, y1) from r:
	 *	// r = (e + x1) mod n
	 *	// x1 \equiv (r - e) (mod n)
	 *	x1 = (r - e) mod n if restrict x1 in [1, n-1]
	 *	g = x1^3 + a*x1 + b (mod p)
	 *	u = (p - 3)/4 + 1
	 *	y1 = g^u (mod p), check y1^2 == g (mod p)
	 *	if (y1 % 2 != v)
			y1 = p - y1
	 */
	function sm2recover(bytes32 hash, uint8 _v, bytes32 _r, bytes32 _s) public returns (address) {
		uint r = uint(_r);
		uint s = uint(_s);
		uint e = uint(hash);
		uint8 v = _v - 27;
		uint x;
		uint y;
		uint z;
		uint g;

		x = submod(r, e, SM2_N);

		g = mulmod(x, x,     SM2_P);
		g = addmod(g, SM2_A, SM2_P);
		g = mulmod(g, x,     SM2_P);
		g = addmod(g, SM2_B, SM2_P);

		y = expmod(g, SM2_U, SM2_P);
		if (mulmod(y, y, SM2_P) != g) {
			return address(0x0);
		}
		if (y & 1 != v) {
			y = SM2_P - y;
		}

		// -Q = (x, -y)
		SM2Point memory Q = SM2Point(x, SM2_P - y, 1);

		// g = -(s + r)^-1 (mod n)
		g = addmod(s, r, SM2_N);
		g = invmod(g, SM2_N);
		g = SM2_N - g;

		SM2Point memory P = scalarMulGenerator(s);
		P = add(P, Q);

		x = P.X;
		y = P.Y;
		z = P.Z;
		z = invmod(z, SM2_P);
		y = mulmod(y, z, SM2_P);
		z = mulmod(z, z, SM2_P);
		x = mulmod(x, z, SM2_P);
		y = mulmod(y, z, SM2_P);

		P = scalarMul(g, SM2Point(x, y, 1));

		// (x, y) = (X/Z^2, Y/Z^3)
		x = P.X;
		y = P.Y;
		z = P.Z;
		z = invmod(z, SM2_P);
		y = mulmod(y, z, SM2_P);
		z = mulmod(z, z, SM2_P);
		x = mulmod(x, z, SM2_P);
		y = mulmod(y, z, SM2_P);

		// generate ethereum address generation
		// replace keccake256 to sm3 in the future
		return address(uint160(uint256(keccak256(abi.encodePacked(x, y)))));
	}

	function sm2verify(bytes32 hash, bytes memory sig) public returns (address) {
		bytes32 r;
		bytes32 s;
		uint8 v;

		if (sig.length != 65) {
			return address(0x0);
		}

		assembly {
			r := mload(add(sig, 32))
			s := mload(add(sig, 64))
			v := add(mload(add(sig, 65)), 255)
		}
		
		if (v < 27) {
			v += 27;
		}

		if (v != 27 && v != 28 && v != 37 && v != 38) {
			return address(0x0);
		}

		return sm2recover(hash, v, r, s);
	}

	function isEqual(SM2Point memory P, SM2Point memory Q) public returns (bool) {
		return isAtInfinity(add(P, neg(Q)));
	}

	function genSig(uint256 x, uint256 y, uint8 v) public returns (bytes memory) {
        bytes memory res = new bytes(65);
        assembly {
			mstore(add(res, 32), x)
			mstore(add(res, 64), y)
			mstore8(add(res, 96), v)
		}
		return res;
    }

	function genHash(uint256 x) public returns (bytes32) {
		return bytes32(x);
    }

	function testField() public returns (bool) {
		SM2Point memory G = SM2Point(SM2_X, SM2_Y, 1);
		assert(isOnCurve(G));
		
		uint r = 0x4aab6dac98f774bf8268269d5177dab84e5e82bb4323d768f7117cc3bf3b6189;
		uint s = 0xe9b330ab81228432961ce806b4ab6898ddc512cc863836e068c627c1e97e91c2;
		
		uint r_sub_s = submod(r, s, SM2_P);
		uint r_div2  = div2mod(r, SM2_P);
		uint r_exp_s = expmod(r, s, SM2_P);
		uint r_inv   = invmod(r, SM2_P);
		uint r_invp  = invmodp(r);
		assert(r_sub_s == 0x60f83d0017d4f08cec4b3e969ccc721f70996fedbceba0898e4b5501d5bccfc6);
		assert(r_div2  == 0xa555b6d5cc7bba5fc134134ea8bbed5c272f415d2191ebb4fb88be61df9db0c4);
		assert(r_exp_s == 0xc3aac2154d0a9c952cd53a7d52266833da40d18692f378f1cadfe00690b0b0bd);
		assert(r_inv   == 0xee295df6b7c057c079ee6a7a9c8dfa8f84f4debed40fcf0d6aa4f38337bba10d);
		assert(r_invp  == 0xee295df6b7c057c079ee6a7a9c8dfa8f84f4debed40fcf0d6aa4f38337bba10d);

		return true;
	}

	function testPoint() public returns (bool) {
		SM2Point memory R = SM2Point(0x8061401c4f5626681f94f46bb956b879535a1ce4c84053b9aa5f84665041a980, 0xf30ff6d94d44360d13863b9bac32a7c4eb4897144d09b6663a67fe2b4b68a4a0, 1);
		SM2Point memory S = SM2Point(0x9619582757fd0fcea01cc42d654b90cc113e4d3527113ddc655278880de57c89, 0x8722774b08e5e0ccc4f959fcadf6bb57e32eb905404e510aa8d549babc7c0baa, 1);
		assert(isOnCurve(R));
		assert(isOnCurve(S));

		uint k = 0xd3aae3f7ba923334977bb7b0af0029fe521af20db2127df12ff2d25be127a661;
		SM2Point memory nR = scalarMul(SM2_N, R);
		SM2Point memory negR = neg(R);
		SM2Point memory dblR = dbl(R);
		SM2Point memory R_add_S = add(R, S);
		SM2Point memory R_sub_S = add(R, neg(S));
		SM2Point memory kR = scalarMul(k, R);
		SM2Point memory kG = scalarMulGenerator(k);
		assert(isAtInfinity(nR));
		assert(isEqual(negR, SM2Point(0x8061401c4f5626681f94f46bb956b879535a1ce4c84053b9aa5f84665041a980, 0xcf00925b2bbc9f2ec79c46453cd583b14b768eab2f6499ac59801d4b4975b5f, 1)));
		assert(isEqual(dblR, SM2Point(0x223f44ae3762f2c3127c325fd0c613f84476e3f0824d2d0dc7dd2a7fb7af371f, 0xc968f53708f0a7e3618c7ef3a4c038f771e9516a2525d55edd87695d9017fc10, 1)));
		assert(isEqual(R_add_S, SM2Point(0xd74c24475d39bbc3ddc454bb59ea1bddb0a1e38e418e5afd2e4ce5975780bf11, 0x3147de9be2fb1a27424af4d074e2d6e73402db6e071a10f5422f5567580e0795, 1)));
		assert(isEqual(R_sub_S, SM2Point(0x5cd18bbc4a9cccb484df3870f216bd6757b92dd03f71f711033bc11619481df0, 0x10536bc6ed2044700b193edc32c5a54c6a534cffc4786c8d1f56474af3e59fb5, 1)));
		assert(isEqual(kR, SM2Point(0xf0ef06241fa581922dc1fcdffa9e8468bbc530cd3bda0e2fd774a84f93bbd6e2, 0x2911d25c8a99ca5f9adab0eca566f2bfaa01f932b1bf59c02f1c5aa3e69d9755, 1)));
		assert(isEqual(kG, SM2Point(0x3335cafb1a0205a320afdb354a76954bced810863739aaf49fbba5f1fa825634, 0x100e83c4af1082f11ad8823b2f1e8e98ac9f3c2f8b602190bc492675aef091b5, 1)));
		
		return true;
	}

	function testSign() public returns (bool) {
		// bytes memory sig = genSig(0x7eaae95db44c417c1d3f0e24f911a029beae982e8f617bfefc69ca39e9866fd6, 0x2dc9efce73d232a549b2fdd1870eb4df7e62a8196cf2862749337627a3d4dfd7, 2);
		// bytes32 hash = genHash(0x4b751e629a4a3bd8fc8f32efae9b0addefd687a85827d10a5cae2447ef0419a2);
		// address res = sm2verify(hash, sig);
		// emit Log("res", res);
		return true;
	}
}

contract sm2_test {
	function test() public returns (bool) {
		SM2Curve.testField();
		SM2Curve.testPoint();
		// SM2Curve.testSign();
		return true;
	}
}
