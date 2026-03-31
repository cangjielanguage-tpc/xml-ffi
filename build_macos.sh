#!/bin/bash
set -euo pipefail

lib_path=$(cd "$(dirname "$0")"; pwd)
out_dir="${lib_path}/libs/aarch64-apple-darwin"
tmp_dir=$(mktemp -d /tmp/xml-ffi-macos.XXXXXX)
sdk_root="${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path)}"
sdk_version="$(xcrun --sdk macosx --show-sdk-version 2>/dev/null || echo 15.0)"
min_target="${MACOSX_DEPLOYMENT_TARGET:-12.0}"

cleanup() {
    rm -rf "${tmp_dir}"
}
trap cleanup EXIT

mkdir -p "${out_dir}"

vendor_libxml2=""
for candidate in \
    "${out_dir}/libxml2.16.dylib" \
    "${out_dir}/libxml2.dylib" \
    "${lib_path}/lib/libxml2.dylib"
do
    if [ -f "${candidate}" ] && [ ! -L "${candidate}" ]; then
        vendor_libxml2="${candidate}"
        break
    fi
done

if [ -z "${vendor_libxml2}" ]; then
    echo "ERROR: missing vendor libxml2 dylib"
    echo "Expected one of:"
    echo "  ${out_dir}/libxml2.16.dylib"
    echo "  ${out_dir}/libxml2.dylib"
    echo "  ${lib_path}/lib/libxml2.dylib"
    exit 1
fi

cp -f "${vendor_libxml2}" "${tmp_dir}/libxml2.raw.dylib"
chmod u+w "${tmp_dir}/libxml2.raw.dylib"
install_name_tool -id @rpath/libxml2.16.dylib "${tmp_dir}/libxml2.raw.dylib"
vtool -set-build-version macos "${min_target}" "${sdk_version}" -replace \
    -output "${tmp_dir}/libxml2.16.dylib" "${tmp_dir}/libxml2.raw.dylib"
strip -x "${tmp_dir}/libxml2.16.dylib" || true

MACOSX_DEPLOYMENT_TARGET="${min_target}" clang \
    -dynamiclib \
    -arch arm64 \
    -mmacosx-version-min="${min_target}" \
    -isysroot "${sdk_root}" \
    -fPIC -Wall -Wextra -Wfloat-equal -std=c11 -std=gnu11 -fstack-protector-strong -O2 \
    -I"${lib_path}/libxml_c/include" \
    -o "${tmp_dir}/libmyxml2.dylib" \
    "${lib_path}/libxml_c/myxml.c" \
    -L"${tmp_dir}" \
    -lxml2.16 \
    -Wl,-install_name,@rpath/libmyxml2.dylib
strip -x "${tmp_dir}/libmyxml2.dylib" || true

rm -f "${out_dir}/libxml2.dylib" "${out_dir}/libxml2.16.dylib"
cp -f "${tmp_dir}/libxml2.16.dylib" "${out_dir}/libxml2.16.dylib"
cp -f "${tmp_dir}/libmyxml2.dylib" "${out_dir}/libmyxml2.dylib"
ln -sfn libxml2.16.dylib "${out_dir}/libxml2.dylib"

echo "Building xml_ffi for macOS arm64 (min target ${min_target})"
cjpm build -V

if [ -d "${lib_path}/target/release/xml_ffi" ]; then
    cp -f "${out_dir}/libxml2.16.dylib" "${lib_path}/target/release/xml_ffi/"
    cp -f "${out_dir}/libmyxml2.dylib" "${lib_path}/target/release/xml_ffi/"
fi

echo "macOS build completed"
