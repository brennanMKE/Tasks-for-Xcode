#!/bin/sh

set -e

Command="$1"

ProjectDir="`dirname \"$0\"`"
Workspace="Tasks.xcworkspace"
Scheme="Tasks"
Project="Tasks.xcodeproj"
Target="Tasks"

TestPlatform="iOS Simulator"
TestName="iPhone 7"
TestOS="10.1"
TestDestination="platform=${TestPlatform},name=${TestName},OS=${TestOS}"

Configuration="Debug"

# No Integrate in Podfile (if you prefer not to use a workspace)
# install! 'cocoapods', :integrate_targets => false

run_build() {
    if [ "" == "${Workspace}" ]; then
        echo "Building Project..."
        xcodebuild -project "${Project}" -target "${Target}" -configuration "${Configuration}" build
    else
        echo "Building Workspace..."
        xcodebuild -workspace "${Workspace}" -scheme "${Scheme}" -configuration "${Configuration}" build
    fi
}

run_tests() {
    if [ "" == "${Workspace}" ]; then
        echo "Testing Project..."
        echo xcodebuild -project "${Project}" -target "${Target}" -destination "${TestDestination}" test | bundle exec xcpretty --test --color
    else
        echo "Testing Workspace..."
        xcodebuild -workspace "${Workspace}" -scheme "${Scheme}" -destination "${TestDestination}" test | bundle exec xcpretty --test --color
    fi
}

run_clean() {
    if [ "" == "${Workspace}" ]; then
        echo "Cleaning Project..."
        xcodebuild -project "${Project}" -target "${Target}" -configuration "${Configuration}" clean
    else
        echo "Cleaning Workspace..."
        xcodebuild -workspace "${Workspace}" -scheme "${Scheme}" -configuration "${Configuration}" clean
    fi
}

run_bundle_install() {
    echo "Installing Gems..."
    bundle install
}

run_pod_install() {
    echo "Installing Pods..."
    bundle exec pod install
}

run_pod_update() {
    echo "Updating Pods..."
    bundle exec pod update
}

run_setup() {
    echo "Setting up..."
    run_bundle_install
    run_pod_install
}

run_all() {
    echo "Setting up..."
    run_clean
    run_bundle_install
    run_pod_install
    run_build
    run_tests
}

case "${Command}" in
    build)
        run_build
        ;;
    test)
        run_tests
        ;;
    clean)
        run_clean
        ;;
    setup)
        run_setup
        ;;
    all)
        run_all
        ;;
    bundle-install)
        run_bundle_install
        ;;
    pod-install)
        run_pod_install
        ;;
    pod-update)
        run_pod_update
        ;;
    *)
        echo "Usage: `basename $0` { build | clean | setup | all | bundle-install | pod-install | pod-update }"
        ;;
esac
