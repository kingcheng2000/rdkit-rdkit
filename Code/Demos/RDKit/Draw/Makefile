

LDFLAGS = -L${RDBASE}/lib  -lSmilesParse_static  \
-lDepictor_static -lSubstructMatch_static -lSubgraphs_static -lGraphMol_static -lDataStructs_static -lRDGeometryLib_static -lRDGeneral_static -lboost_system

ifndef BOOSTHOME
  BOOSTHOME=/usr/local/include
endif
CPPFLAGS = -g -I${BOOSTHOME} -I${RDBASE}/Code -Wno-deprecated $(shell pkg-config --cflags cairo)

%.o : %.cpp MolDrawing.h
	$(CXX) $(CPPFLAGS)  -c -o $@ $< 

demo.exe: demo.o 
	$(CXX)  -o $@ $< $(LDFLAGS) $(shell pkg-config --libs cairo)
