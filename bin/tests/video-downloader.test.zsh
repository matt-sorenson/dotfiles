#!/usr/bin/env zsh

source "${DOTFILES}/bin/tests/harness.zsh"

autoload video-downloader

root="${DOTFILES}/bin/tests/video-downloader-env"

mock_video_downloader() {
    print "mock_video_downloader: $*"
}

url-and-file() {
    touch "${root}/url-and-file"

    if video-downloader "https://example.com/v/id" "${root}/url-and-file" --downloader-cmd mock_video_downloader; then
        print-header -e "passing in both file and url didn't fail!"
        return 1
    fi

    if [[ -f "${PWD}/video-downloader.done" ]]; then
        print-header -e "${PWD}/video-downloader.done file not cleaned up"
    fi

    rm -f "${root}/url-and-file"

    return 0
}

url() {
    video-downloader "https://example.com/v/id" \
        --downloader-cmd mock_video_downloader

    if [[ -f "${PWD}/video-downloader.done" ]]; then
        print-header -e "${PWD}/video-downloader.done file not cleaned up"
    fi
}

file() {
    print "https://example.com/v/1\nhttps://example.com/v/2" > "${root}/test-file"

    video-downloader "${root}/test-file" \
        --downloader-cmd mock_video_downloader

    if [[ -f "${root}/test-file.done" ]]; then
        print-header -e "${root}/test-file.done file not cleaned up"
    fi

    rm -f "${root}/test-file"
}

no-cleanup() {
    video-downloader "https://example.com/v/1" \
        --output "${root}" \
        --downloader-cmd mock_video_downloader \
        --done-filename no-cleanup.done \
        --no-cleanup

    if [[ ! -f "${root}/no-cleanup.done" ]]; then
        print-header -e "--no-cleanup passed in but file is missing"
    else
        rm -f "${root}/no-cleanup.done"
    fi
}

main() {
    mkdir -p "${root}"

    local out=0
    local testee='video-downloader'
    local -a test_cases=(
        url-and-file
        url
        file
        no-cleanup
    )

    for element in "${test_cases[@]}"; do
        run-test "$testee" "$element" || (( out += 1 ))
    done

    rm -rf "${root}"

    return $out
}

main "$@"
