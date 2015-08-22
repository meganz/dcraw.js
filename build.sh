#!/bin/bash

# -s ASSERTIONS=0 -s RELOOP=1 -s CORRECT_ROUNDINGS=0 -s QUANTUM_SIZE=4 -s NO_BROWSER=1 

cat dcraw.c \
	| sed -e 's/argc == 1/0/' \
	| sed -re 's/\((write_to_stdout|verbose)\)/(0)/' \
	| sed -e 's/putenv/if(0)&/' > dcraw.tmp.c

emcc -Oz -g1 --llvm-lto 1 -s ASM_JS=1 -s INVOKE_RUN=0 -s NO_EXIT_RUNTIME=1 -s ALLOW_MEMORY_GROWTH=1 \
	-s EXPORT_NAME=\"DCRawMod\" -s USE_TYPED_ARRAYS=2 -s NO_DYNAMIC_EXECUTION=1 -s CORRECT_SIGNS=0 \
	-s DISABLE_EXCEPTION_CATCHING=1 -s CORRECT_OVERFLOWS=0 -s MEMFS_APPEND_TO_TYPED_ARRAYS=1 \
	-s WARN_ON_UNDEFINED_SYMBOLS=0 -s DEFAULT_LIBRARY_FUNCS_TO_INCLUDE="['memcpy','memset','malloc','free','strlen']" \
	-s USE_SDL=0 -s AGGRESSIVE_VARIABLE_ELIMINATION=1 -s DOUBLE_MODE=0 -s PRECISE_I64_MATH=0 \
	-o dcraw.js -DNODEPS -Wno-warn-absolute-paths dcraw.tmp.c \
	--memory-init-file 0

cat dcraw.js \
	| sed -e 's/var ENVIRONMENT_IS_NODE =/\/\/NODE/' \
	| sed -e 's/var ENVIRONMENT_IS_SHELL =/\/\/SHELL/' \
	| sed -e 's/ENVIRONMENT_IS_NODE/0/' \
	| sed -e 's/ENVIRONMENT_IS_SHELL/0/' \
	| sed -e 's/var memoryInitializer/\/\/&/' \
	| sed -e 's/memoryInitializer/0/' \
	| sed -e 's/typeof console/global.d\&\&&/' \
	| sed -e 's/window\["DCRawMod"\]/if\(global.d\) &/' \
	| sed -e 's/Browser.initted/1/' \
	| sed -e 's/Module\["read/1\?0\:&/' \
	| sed -re 's/Module\["(FS|addRunDependency|removeRunDependency|preloadedImages|preloadedAudios)/\/\//' \
	| sed -e 's/createPreloadedFile:/& 0\&\&/' \
	| sed -e 's/createLazyFile:/& 0\&\&/' \
	| sed -e 's/forceLoadFile:/& 0\&\&/' \
	| sed -e 's/indexedDB:/& 0\&\&/' \
	| sed -e 's/DB_NAME:/& 0\&\&/' \
	| sed -e 's/DB_VERSION:/& 0\&\&/' \
	| sed -e 's/DB_STORE_NAME:/& 0\&\&/' \
	| sed -e 's/saveFilesToDB:/& 0\&\&/' \
	| sed -e 's/loadFilesFromDB:/& 0\&\&/' \
	| sed -e 's/getCompilerSetting:/K: 0\&\&/' \
	| sed -e 's/getAsmConst:/J: 0\&\&/' \
	| sed -e 's/generateStructInfo:/L: 0\&\&/' \
	| sed -e 's/calculateStructAlignment:/M: 0\&\&/' \
	| sed -re 's/function (demangleAll|addRunDependency|removeRunDependency)/if(0) var __R=&/' \
	| sed -re 's/function (_recv|_send)/function \1\(\)\{\};if(0) var __R=&/' \
	| sed -e 's/demangleAll//' \
	| sed -e 's/var SOCKFS/if(0)&/' \
	| sed -e 's/ SOCKFS.root/\/\/&/' \
	| sed -e 's/var NODEFS/if(0)&/' \
	| sed -e 's/var IDBFS/if(0)&/' \
	| sed -e 's/var Browser/if(0)&/' \
	| sed -e 's/var i64Math/if(0) var UYDgkasj/' \
	| sed -e 's/i64Math/0/' \
			| sed -e 's/if (_tmpfile.mode)/if (!_tmpfile.mode)/' \
			| sed -e 's/var folder \= FS\.findObject/dir=dir\|\|"\/tmp";&/' \
	| sed -e 's/web_user/diegocr/' \
	| sed -e 's/postRun();/else run=Module\.callMain;&/' \
	| sed -e 's/this.program/dcraw/' > dcraw.tmp.js

# NB: indented SEDs are bugfixes on emscripten 1.22

echo "exports.ver=1.476;exports.run=run;exports.FS=FS;Object.freeze(exports);" >> dcraw.tmp.js

# uglifyjs -m -c --wrap=dcraw --stats --screw-ie8 -o dcraw.tmpx.js dcraw.tmp.js
# cat ./LICENSE.txt dcraw.tmpx.js > dcraw.min.js

uglifyjs -c pure_getters=true -b indent-level=1,width=8192 --wrap=dcraw --stats --screw-ie8 -o dcraw.tmpx.js dcraw.tmp.js
cat ./LICENSE.txt dcraw.tmpx.js > dcraw.js

rm -v dcraw.tmp*
