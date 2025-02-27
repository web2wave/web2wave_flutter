run:
	dart run example/web2wave_example.dart

prepare:
	flutter clean && flutter pub get

version:
	@set -e; \
	perl -i -pe 's/^(version:\s+\d+\.\d+\.)(\d+)$$/sprintf("%s%d", $$1, $$2+1)/e' pubspec.yaml; \
	version=$$(grep 'version: ' pubspec.yaml | sed 's/version: //'); \
	echo "Updated version: $$version"

publish:
	@make prepare
	@make version
	dart pub publish