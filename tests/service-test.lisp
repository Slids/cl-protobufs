;;; Copyright 2020 Google LLC
;;;
;;; Use of this source code is governed by an MIT-style
;;; license that can be found in the LICENSE file or at
;;; https://opensource.org/licenses/MIT.

(defpackage #:cl-protobufs.test.services
  (:use #:cl
        #:clunit
        #:cl-protobufs.protobuf-package-unittest1
        #:cl-protobufs.protobuf-package-unittest1-rpc
        #:cl-protobufs.service-test-pb
        #:cl-protobufs.service-test-pb-rpc)
  (:export :run))

(in-package #:cl-protobufs.test.services)

(defsuite services-suite (cl-protobufs.test:root-suite))

(defun run ()
  "Run all tests in the test suite."
  (cl-protobufs.test:run-suite 'services-suite))

(deftest test-service-name-is-exported (services-suite)
  (assert-true 'cl-protobufs.protobuf-package-unittest1:service-with-cross-package-input-output))

(deftest test-rpc-method-names-are-exported (services-suite)
  (assert-true 'cl-protobufs.protobuf-package-unittest1-rpc:bloop-impl)
  (assert-true 'cl-protobufs.protobuf-package-unittest1-rpc:call-bloop)
  (assert-true 'cl-protobufs.protobuf-package-unittest1-rpc:beep-impl)
  (assert-true 'cl-protobufs.protobuf-package-unittest1-rpc:call-beep))

(deftest test-camel-spitting-request (services-suite)
  (let* ((service
          (proto:find-service
           'cl-protobufs.protobuf-package-unittest1:package_test1
           'cl-protobufs.protobuf-package-unittest1:service-with-camel-spitting-input-output))
         (method (proto-impl::find-method
                  service
                  'cl-protobufs.protobuf-package-unittest1::record2f-lookup))
         (input (proto-impl::proto-input-name method))
         (output (proto-impl::proto-output-name method)))
    ;; Input/output names must be fully qualified.
    (assert-true (string= "protobuf_package_unittest1.Record2fLookupRequest" input))
    (assert-true (string= "protobuf_package_unittest1.Record2fLookupResponse" output))))

(deftest test-method-options (services-suite)
  (let* ((service (proto:find-service 'cl-protobufs.service-test-pb:service-test
                                      'cl-protobufs.service-test-pb:foo-service))
         (method (proto-impl::find-method service 'cl-protobufs.service-test-pb::bar-method)))
    (assert-true (eq :udp (proto-impl::find-option method "protocol")))
    (assert-true (eql 30.0d0 (proto-impl::find-option method "deadline")))
    (assert-true (eq t (proto-impl::find-option method "duplicate_suppression")))
    (assert-true (eql -123 (proto-impl::find-option method "client_logging")))
    (assert-true (eq :privacy-and-integrity (proto-impl::find-option method "security_level")))
    (assert-true (equal "admin" (proto-impl::find-option method "security_label")))
    (assert-true (eql 42 (proto-impl::find-option method "legacy_client_initial_tokens")))))
