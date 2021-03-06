--
-- first, define the datatype.  Turn off echoing so that expected file
-- does not depend on contents of rdkit.sql.
--
SET client_min_messages = warning;
\set ECHO none
CREATE EXTENSION rdkit;
\set ECHO all
RESET client_min_messages;

SELECT is_valid_smiles('c1ccccc1');
SELECT mol_from_smiles('c1ccccc1');
SELECT is_valid_smiles('c1ccccc');
SELECT mol_from_smiles('c1ccccc');
SELECT mol_from_smiles('cccccc');
SELECT is_valid_smiles('c1cccn1');
SELECT is_valid_smarts('c1ccc[n,c]1');
SELECT mol_from_smarts('c1ccc[n,c]1');
SELECT is_valid_smarts('c1ccc');
SELECT mol_from_smarts('c1ccc');
SELECT mol_to_smiles(mol_from_smiles('c1ccccc1'));
SELECT mol_to_smarts(mol_from_smiles('c1ccccc1'));
SELECT mol_to_smarts('c1cccc[n,c]1'::qmol);
SELECT mol_to_smiles('c1cccc[n,c]1'::qmol);


CREATE TABLE pgmol (id int, m mol);
\copy pgmol from 'data/data'

CREATE UNIQUE INDEX mol_ididx ON pgmol (id);

SELECT count(*) FROM pgmol;

SELECT count(*) FROM pgmol WHERE m @> 'c1ccccc1';
SELECT count(*) FROM pgmol WHERE m @> 'c1cccnc1';
SELECT count(*) FROM pgmol WHERE 'c1ccccc1' <@ m;
SELECT count(*) FROM pgmol WHERE 'c1cccnc1' <@ m;

SELECT count(*) FROM pgmol WHERE m @> mol_from_smarts('c1ccccc1');
SELECT count(*) FROM pgmol WHERE m @> mol_from_smarts('c1cccnc1');
SELECT count(*) FROM pgmol WHERE m @> mol_from_smarts('c1ccc[n,c]c1');
SELECT count(*) FROM pgmol WHERE mol_from_smarts('c1ccccc1') <@ m;
SELECT count(*) FROM pgmol WHERE mol_from_smarts('c1ccc[n,c]c1') <@ m;


SELECT id, rdkit_fp(m) AS f INTO pgbfp FROM pgmol;
CREATE UNIQUE INDEX bfp_ididx ON pgbfp (id);

SELECT id, morgan_fp(m,1) AS f INTO pgsfp FROM pgmol;
CREATE UNIQUE INDEX sfp_ididx ON pgsfp (id);

SELECT id, torsion_fp(m) AS f INTO pgtorsfp FROM pgmol;
SELECT id, atompair_fp(m) AS f INTO pgpairfp FROM pgmol;

set rdkit.tanimoto_threshold=0.5;
set rdkit.dice_threshold=0.5;

SELECT 
	id, 
	tanimoto_sml(rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol), f) 
FROM
	 (SELECT * FROM pgbfp ORDER BY id) AS t 
WHERE rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol) % f  
LIMIT 10;

SELECT 
	id, 
	dice_sml(rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol), f) 
FROM
	 (SELECT * FROM pgbfp ORDER BY id) AS t 
WHERE rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol) % f  
LIMIT 10;

SELECT 
	id, 
	tanimoto_sml(rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol), f) 
FROM
	 (SELECT * FROM pgbfp ORDER BY id) AS t 
WHERE rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol) # f  
LIMIT 10;

SELECT 
	id, 
	dice_sml(rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol), f),
	size(f)
FROM
	 (SELECT * FROM pgbfp ORDER BY id) AS t 
WHERE rdkit_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol) # f  
LIMIT 10;

set rdkit.tanimoto_threshold=0.4;
SELECT 
	id, 
	tanimoto_sml(morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)))'::mol, 1), f) 
FROM
	 (SELECT * FROM pgsfp ORDER BY id) AS t 
WHERE morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)))'::mol, 1) % f  
LIMIT 10;

SELECT 
	id, 
	dice_sml(morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)))'::mol, 1), f) 
FROM
	 (SELECT * FROM pgsfp ORDER BY id) AS t 
WHERE morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)))'::mol, 1) % f  
LIMIT 10;

SELECT 
	id, 
	tanimoto_sml(morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), f) 
FROM
	 (SELECT * FROM pgsfp ORDER BY id) AS t 
WHERE morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1) # f  
LIMIT 10;

SELECT 
	id, 
	dice_sml(morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), f)
FROM
	 (SELECT * FROM pgsfp ORDER BY id) AS t 
WHERE morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1) # f  
LIMIT 10;

select dice_sml(morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), morgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)N)'::mol, 1)) sml;

select dice_sml(featmorgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), featmorgan_fp('C1C(OC2=CC(=CC(=C2C1=O)O)N)'::mol, 1)) sml;

select dice_sml(morganbv_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), morganbv_fp('C1C(OC2=CC(=CC(=C2C1=O)O)N)'::mol, 1)) sml;

select dice_sml(featmorganbv_fp('C1C(OC2=CC(=CC(=C2C1=O)O)O)'::mol, 1), featmorganbv_fp('C1C(OC2=CC(=CC(=C2C1=O)O)N)'::mol, 1)) sml;

select 'Cc1ccccc1'::mol@='c1ccccc1C'::mol;
select 'Cc1ccccc1'::mol@='c1ccccc1CC'::mol;
select 'Cc1ccccc1'::mol@='c1cccnc1C'::mol;

select subtract(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=subtract(torsion_fp('CCC1CCOCC1'),torsion_fp('OCC1CCOCC1'));
select subtract(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=subtract(torsion_fp('CCC1CCOCC1'),torsion_fp('NCC1CCOCC1'));
select add(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=add(torsion_fp('CCC1CCOCC1'),torsion_fp('OCC1CCOCC1'));
select add(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=add(torsion_fp('CCC1CCOCC1'),torsion_fp('NCC1CCOCC1'));

select add(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=subtract(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'));
select add(torsion_fp('CCC1CCNCC1'),torsion_fp('OCC1CCNCC1'))=subtract(torsion_fp('CCC1CCOCC1'),torsion_fp('OCC1CCOCC1'));

select is_valid_ctab('chiral1.mol
  ChemDraw04200416412D

  5  4  0  0  0  0  0  0  0  0999 V2000
   -0.0141    0.0553    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
    0.8109    0.0553    0.0000 F   0  0  0  0  0  0  0  0  0  0  0  0
   -0.4266    0.7697    0.0000 Br  0  0  0  0  0  0  0  0  0  0  0  0
   -0.0141   -0.7697    0.0000 Cl  0  0  0  0  0  0  0  0  0  0  0  0
   -0.8109   -0.1583    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
  1  2  1  0      
  1  3  1  0      
  1  4  1  1      
  1  5  1  0      
M  END');
select is_valid_ctab('invalid');
select mol_from_ctab('chiral1.mol
  ChemDraw04200416412D

  5  4  0  0  0  0  0  0  0  0999 V2000
   -0.0141    0.0553    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
    0.8109    0.0553    0.0000 F   0  0  0  0  0  0  0  0  0  0  0  0
   -0.4266    0.7697    0.0000 Br  0  0  0  0  0  0  0  0  0  0  0  0
   -0.0141   -0.7697    0.0000 Cl  0  0  0  0  0  0  0  0  0  0  0  0
   -0.8109   -0.1583    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
  1  2  1  0      
  1  3  1  0      
  1  4  1  1      
  1  5  1  0      
M  END');

select all_values_lt(torsion_fp('c1ccccc1C'::mol),2);
select all_values_lt(torsion_fp('c1ccccc1C'::mol),3);
select all_values_gt(torsion_fp('c1ccccc1C'::mol),1);
select all_values_gt(torsion_fp('c1ccccc1C'::mol),2);

select is_valid_mol_pkl('foo'::bytea);
select is_valid_mol_pkl(mol_to_pkl('c1ccccc1'::mol));
select mol_from_pkl(mol_to_pkl('c1ccccc1'::mol));

select tanimoto_sml(morganbv_fp('c1ccccn1'::mol),morganbv_fp('c1ccccc1'::mol));
select tanimoto_sml(bfp_from_binary_text(bfp_to_binary_text(morganbv_fp('c1ccccn1'::mol))),
                    bfp_from_binary_text(bfp_to_binary_text(morganbv_fp('c1ccccc1'::mol))));
